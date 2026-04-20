# typed: ignore
# frozen_string_literal: true

require_relative '../test_helper'
require 'webmock'
require_relative '../../lib/soren/webmock'

module Soren
  class WebMockTest < Minitest::Test
    include WebMock::API

    def setup
      WebMock.enable!
      WebMock.disable_net_connect!
    end

    def teardown
      WebMock.reset!
      WebMock.allow_net_connect!
    end

    def test_returns_stubbed_response_for_get_request
      stub_request(:get, 'http://example.com/hello')
        .to_return(status: 200, body: 'hello world', headers: { 'Content-Type' => 'text/plain' })

      response = connection('http').send(request(:get, '/hello'))

      assert_equal 200, response.code
      assert_equal 'hello world', response.body
      assert_equal ['text/plain'], response.headers['content-type']
    end

    def test_returns_stubbed_response_for_post_request_with_body
      stub_request(:post, 'http://example.com/data')
        .with(body: '{"key":"value"}')
        .to_return(status: 201, body: 'created', headers: {})

      response = connection('http').send(request(:post, '/data', body: '{"key":"value"}'))

      assert_equal 201, response.code
      assert_equal 'created', response.body
    end

    def test_raises_when_net_connect_blocked_and_no_stub_matches
      assert_raises(WebMock::NetConnectNotAllowedError) do
        connection('http').send(request(:get, '/unstubbed'))
      end
    end

    def test_stub_with_multiple_response_headers
      stub_request(:get, 'http://example.com/multi')
        .to_return(
          status:  200,
          body:    '',
          headers: { 'Set-Cookie' => ['a=1', 'b=2'], 'X-Custom' => 'value' },
        )

      response = connection('http').send(request(:get, '/multi'))

      assert_equal ['a=1', 'b=2'], response.headers['set-cookie']
      assert_equal ['value'], response.headers['x-custom']
    end

    def test_stub_with_non_ok_status_and_message
      stub_request(:get, 'http://example.com/gone')
        .to_return(status: [404, 'Not Found'], body: 'missing')

      response = connection('http').send(request(:get, '/gone'))

      assert_equal 404, response.code
      assert_equal 'Not Found', response.message
      assert_equal 'missing', response.body
    end

    def test_records_request_signature_for_assertion
      stub_request(:get, 'http://example.com/check').to_return(status: 200, body: '')

      connection('http').send(request(:get, '/check'))

      assert_requested :get, 'http://example.com/check'
    end

    private

    def connection(scheme)
      Soren::Connection.new(host: 'example.com', port: 80, scheme: scheme)
    end

    def request(method, target, body: nil, headers: {})
      Soren::Request.new(method: method, target: target, body: body, headers: headers)
    end
  end
end
