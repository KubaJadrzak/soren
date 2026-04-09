# frozen_string_literal: true

require 'test_helper'
require 'uri'
require 'stringio'
require 'json'

require_relative '../lib/soren/request'

class TestSoren < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Soren::VERSION
  end

  def test_open_socket_uses_host_and_port
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'http')
    fake_socket = Object.new

    tcp_socket_stub = ->(host, port, connect_timeout:) do
      assert_equal 'example.com', host
      assert_equal 443, port
      assert_operator connect_timeout, :>, 0.0
      assert_operator connect_timeout, :<=, Soren::Defaults::Options::CONNECT_TIMEOUT
      fake_socket
    end

    socket = Socket.stub(:tcp, tcp_socket_stub) do
      connection.open_socket
    end

    assert_same fake_socket, socket
  end

  def test_open_socket_wraps_tcp_errors
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'http')

    error = Socket.stub(:tcp, ->(*_) { raise ::SocketError, 'boom' }) do
      assert_raises(Soren::Error::DNSFailure) { connection.open_socket }
    end

    assert_match(/DNS lookup failed: boom/, error.message)
  end

  def test_open_socket_wraps_ssl_errors
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'https')
    fake_tcp = Object.new

    fake_tcp.define_singleton_method(:close) { true }

    error = Socket.stub(:tcp, ->(*_) { fake_tcp }) do
      OpenSSL::SSL::SSLSocket.stub(:new, ->(*_) { raise OpenSSL::SSL::SSLError, 'handshake failed' }) do
        assert_raises(Soren::Error::SSLError) { connection.open_socket }
      end
    end

    assert_match(/SSL error: handshake failed/, error.message)
  end

  def test_open_socket_raises_timeout_when_ssl_connect_is_not_writable
    connection = Soren::Connection.new(
      host:    'example.com',
      port:    443,
      scheme:  'https',
      options: { connect_timeout: 0.1 },
    )

    fake_tcp = Object.new
    fake_tcp.define_singleton_method(:close) { true }

    wait_writable_error_class = Class.new(StandardError) do
      include IO::WaitWritable
    end

    fake_ssl = Object.new
    fake_ssl.define_singleton_method(:hostname=) { |_host| true }
    fake_ssl.define_singleton_method(:connect_nonblock) { raise wait_writable_error_class, 'wait writable' }
    fake_ssl.define_singleton_method(:to_io) { self }
    fake_ssl.define_singleton_method(:wait_writable) { |_timeout| nil }

    error = Socket.stub(:tcp, ->(*_) { fake_tcp }) do
      OpenSSL::SSL::SSLSocket.stub(:new, ->(*_) { fake_ssl }) do
        assert_raises(Soren::Error::TimeoutError) { connection.open_socket }
      end
    end

    assert_equal 'SSL connect timeout', error.message
  end

  def test_open_socket_wraps_timeout_errors
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'http')

    error = Socket.stub(:tcp, ->(*_) { raise Errno::ETIMEDOUT, 'timed out' }) do
      assert_raises(Soren::Error::TimeoutError) { connection.open_socket }
    end

    assert_match(/connection timeout:/, error.message)
    assert_match(/timed out/i, error.message)
  end

  def test_send_uses_open_socket_and_request_to_http
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'https')
    written_payload = nil
    closed = false
    captured_host = nil
    response_payload = StringIO.new("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 11\r\n\r\n{\"ok\":true}")

    fake_socket = Object.new
    fake_socket.define_singleton_method(:write_nonblock) do |payload|
      written_payload = payload
      payload.bytesize
    end
    fake_socket.define_singleton_method(:gets) { response_payload.gets }
    fake_socket.define_singleton_method(:read) { |length = nil| response_payload.read(length) }
    fake_socket.define_singleton_method(:close) do
      closed = true
    end

    fake_request = Object.new
    fake_request.define_singleton_method(:to_http) do |host:|
      captured_host = host
      "GET / HTTP/1.1\r\nHost: #{host}\r\n\r\n"
    end

    response = connection.stub(:open_socket, fake_socket) do
      connection.send(fake_request)
    end

    assert_equal 'example.com', captured_host
    assert_equal "GET / HTTP/1.1\r\nHost: example.com\r\n\r\n", written_payload
    assert_instance_of Soren::Response, response
    assert_equal 200, response.status_code.to_i
    assert_equal 'OK', response.status_message.to_s
    assert_equal 'HTTP/1.1', response.version.to_s
    assert_equal({ 'content-type' => ['application/json'], 'content-length' => ['11'] }, response.headers.to_h)
    assert_equal '{"ok":true}', response.body.to_s
    assert_equal true, closed
  end

  def test_send_raises_write_timeout_when_socket_not_writable
    connection = Soren::Connection.new(
      host:    'example.com',
      port:    443,
      scheme:  'https',
      options: { write_timeout: 0.0 },
    )
    closed = false

    fake_socket = Object.new
    fake_socket.define_singleton_method(:write_nonblock) do |_payload|
      raise IO::WaitWritable
    end
    fake_socket.define_singleton_method(:close) do
      closed = true
    end

    fake_request = Object.new
    fake_request.define_singleton_method(:to_http) do |host:|
      "GET / HTTP/1.1\r\nHost: #{host}\r\n\r\n"
    end

    error = connection.stub(:open_socket, fake_socket) do
      assert_raises(Soren::Error::WriteTimeout) { connection.send(fake_request) }
    end

    assert_equal true, closed
    assert_instance_of Soren::Error::WriteTimeout, error
  end

  def test_real_http_requests_for_supported_methods
    connection = Soren::Connection.new(
      host:    'httpbin.org',
      port:    443,
      scheme:  'https',
      options: { connect_timeout: 10.0, write_timeout: 10.0, read_timeout: 20.0 },
    )

    %w[get post put patch delete].each do |http_method|
      request = Soren::Request.new(
        method:  http_method,
        target:  '/anything/soren-real-http-test',
        headers: { 'Accept' => 'application/json' },
      )

      response = connection.send(request)
      assert_equal 200, response.status_code.to_i, "unexpected status for #{http_method}"

      payload = JSON.parse(response.body.to_s)
      assert_equal http_method.upcase, payload['method'], "unexpected echoed method for #{http_method}"
    end
  rescue Soren::Error::Base, SystemCallError, IOError, ::SocketError => e
    skip "internet integration unavailable: #{e.class}: #{e.message}"
  end

  def test_real_http_requests_for_supported_methods_over_http
    connection = Soren::Connection.new(
      host:    'httpbin.org',
      port:    80,
      scheme:  'http',
      options: { connect_timeout: 10.0, write_timeout: 10.0, read_timeout: 20.0 },
    )

    %w[get post put patch delete].each do |http_method|
      request = Soren::Request.new(
        method:  http_method,
        target:  '/anything/soren-real-http-test',
        headers: { 'Accept' => 'application/json' },
      )

      response = connection.send(request)
      assert_equal 200, response.status_code.to_i, "unexpected status for #{http_method}"

      payload = JSON.parse(response.body.to_s)
      assert_equal http_method.upcase, payload['method'], "unexpected echoed method for #{http_method}"
    end
  rescue Soren::Error::Base, SystemCallError, IOError, ::SocketError => e
    skip "internet integration unavailable: #{e.class}: #{e.message}"
  end

  def test_new_accepts_explicit_host_port_and_scheme
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'https')

    assert_instance_of Soren::Connection, connection
    assert_instance_of Soren::Options, connection.options
    assert_equal Soren::Defaults::Options::READ_TIMEOUT, connection.options.read_timeout.to_f
    assert_equal Soren::Defaults::Options::CONNECT_TIMEOUT, connection.options.connect_timeout.to_f
    assert_equal Soren::Defaults::Options::WRITE_TIMEOUT, connection.options.write_timeout.to_f
  end

  def test_new_accepts_options_hash
    connection = Soren::Connection.new(
      host:    'example.com',
      port:    443,
      scheme:  'https',
      options: { read_timeout: '1.25', 'connect_timeout' => 2, write_timeout: 3.5 },
    )

    assert_equal 1.25, connection.options.read_timeout.to_f
    assert_equal 2.0, connection.options.connect_timeout.to_f
    assert_equal 3.5, connection.options.write_timeout.to_f
  end

  def test_new_rejects_unsupported_options
    error = assert_raises(Soren::Error::ArgumentError) do
      Soren::Connection.new(
        host:    'example.com',
        port:    443,
        scheme:  'https',
        options: { unknown_timeout: 1.0 },
      )
    end

    assert_equal 'unsupported option: unknown_timeout', error.message
  end

  def test_new_accepts_uri_object
    connection = Soren::Connection.new(uri: URI('https://example.com/test'))

    assert_instance_of Soren::Connection, connection
    assert_equal 'example.com', connection.instance_variable_get(:@host).to_s
    assert_equal 443, connection.instance_variable_get(:@port).to_i
    assert_equal 'https', connection.instance_variable_get(:@scheme).to_s
  end

  def test_new_rejects_uri_with_explicit_parts
    error = assert_raises(Soren::Error::ArgumentError) do
      Soren::Connection.new(uri: URI('https://example.com'), host: 'example.com', port: 443, scheme: 'https')
    end

    assert_equal 'pass either uri: or host:, port:, and scheme:, not both', error.message
  end

  def test_new_requires_complete_explicit_parts_without_uri
    error = assert_raises(Soren::Error::ArgumentError) do
      Soren::Connection.new(host: 'example.com', port: 443)
    end

    assert_equal 'scheme must be a non-empty String', error.message
  end
end
