# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/soren/request'

module Soren
  class RequestTest < Minitest::Test
    def test_stores_method
      request = Request.new(method: 'GET', target: '/users')

      assert_equal 'get', request.method.to_s
    end

    def test_stores_symbol_method
      request = Request.new(method: :post, target: '/users')

      assert_equal 'post', request.method.to_s
    end

    def test_stores_target
      request = Request.new(method: 'get', target: '/users')

      assert_equal '/users', request.target.to_s
    end

    def test_stores_target_with_query_string
      request = Request.new(method: 'get', target: '/users?page=1')

      assert_equal '/users?page=1', request.target.to_s
    end

    def test_stores_headers
      request = Request.new(method: 'get', target: '/users', headers: { 'Accept' => 'application/json' })

      assert_equal({ 'Accept' => 'application/json' }, request.headers.to_h)
    end

    def test_stores_body
      request = Request.new(method: 'post', target: '/users', body: '{"name":"Alice"}')

      assert_equal '{"name":"Alice"}', request.body.to_s
    end

    def test_headers_defaults_to_empty_hash
      request = Request.new(method: 'get', target: '/users')

      assert_equal({}, request.headers.to_h)
    end

    def test_body_defaults_to_nil
      request = Request.new(method: 'get', target: '/users')

      assert_nil request.body.to_s
    end

    def test_rejects_invalid_method
      error = assert_raises(Soren::Error::ArgumentError) do
        Request.new(method: 'options', target: '/users')
      end

      assert_equal 'method must be one of get, post, put, patch, delete', error.message
    end

    def test_to_http_without_headers_or_body
      request = Request.new(method: 'get', target: '/users?page=1')

      assert_equal "GET /users?page=1 HTTP/1.1\r\nHost: example.com\r\n\r\n", request.to_http(host: 'example.com')
    end

    def test_to_http_with_headers_and_body
      request = Request.new(
        method:  :post,
        target:  '/users',
        headers: {
          'Content-Type' => 'application/json',
          'Accept'       => 'application/json',
        },
        body:    '{"name":"Alice"}',
      )

      expected_http = [
        'POST /users HTTP/1.1',
        'Content-Type: application/json',
        'Accept: application/json',
        'Host: example.com',
        '',
        '{"name":"Alice"}',
      ].join("\r\n")

      assert_equal expected_http, request.to_http(host: 'example.com')
    end

    def test_to_http_does_not_duplicate_host_header
      request = Request.new(
        method:  :get,
        target:  '/users',
        headers: { 'Host' => 'api.example.com' },
      )

      expected_http = [
        'GET /users HTTP/1.1',
        'Host: api.example.com',
        '',
        '',
      ].join("\r\n")

      assert_equal expected_http, request.to_http(host: 'example.com')
    end
  end
end
