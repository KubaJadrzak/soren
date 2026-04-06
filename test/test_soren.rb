# frozen_string_literal: true

require 'test_helper'
require 'uri'
require 'stringio'

class TestSoren < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Soren::VERSION
  end

  def test_open_socket_uses_host_and_port
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'http')
    fake_socket = Object.new

    tcp_socket_stub = ->(host, port) do
      assert_equal 'example.com', host
      assert_equal 443, port
      fake_socket
    end

    socket = TCPSocket.stub(:new, tcp_socket_stub) do
      connection.open_socket
    end

    assert_same fake_socket, socket
  end

  def test_open_socket_wraps_tcp_errors
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'http')

    error = TCPSocket.stub(:new, ->(*_) { raise ::SocketError, 'boom' }) do
      assert_raises(Soren::Error::DNSFailure) { connection.open_socket }
    end

    assert_match(/DNS lookup failed: boom/, error.message)
  end

  def test_open_socket_wraps_ssl_errors
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'https')
    fake_tcp = Object.new

    fake_tcp.define_singleton_method(:close) { true }

    error = TCPSocket.stub(:new, ->(*_) { fake_tcp }) do
      OpenSSL::SSL::SSLSocket.stub(:new, ->(*_) { raise OpenSSL::SSL::SSLError, 'handshake failed' }) do
        assert_raises(Soren::Error::SSLError) { connection.open_socket }
      end
    end

    assert_match(/SSL error: handshake failed/, error.message)
  end

  def test_open_socket_wraps_timeout_errors
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'http')

    error = TCPSocket.stub(:new, ->(*_) { raise Errno::ETIMEDOUT, 'timed out' }) do
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
    fake_socket.define_singleton_method(:write) do |payload|
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

  def test_new_accepts_explicit_host_port_and_scheme
    connection = Soren::Connection.new(host: 'example.com', port: 443, scheme: 'https')

    assert_instance_of Soren::Connection, connection
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

    assert_equal 'host, port, and scheme are required when uri is not provided', error.message
  end
end
