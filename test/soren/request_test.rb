require_relative '../test_helper'
require_relative '../../lib/soren/request'

module Soren
  class RequestTest < Minitest::Test
    def test_stores_target
      request = Request.new(target: '/users')

      assert_equal '/users', request.target.to_s
    end

    def test_stores_target_with_query_string
      request = Request.new(target: '/users?page=1')

      assert_equal '/users?page=1', request.target.to_s
    end

    def test_stores_headers
      request = Request.new(target: '/users', headers: { 'Accept' => 'application/json' })

      assert_equal({ 'Accept' => 'application/json' }, request.headers.to_h)
    end

    def test_stores_body
      request = Request.new(target: '/users', body: '{"name":"Alice"}')

      assert_equal '{"name":"Alice"}', request.body.to_s
    end

    def test_headers_defaults_to_empty_hash
      request = Request.new(target: '/users')

      assert_equal({}, request.headers.to_h)
    end

    def test_body_defaults_to_nil
      request = Request.new(target: '/users')

      assert_nil request.body.to_s
    end
  end
end
