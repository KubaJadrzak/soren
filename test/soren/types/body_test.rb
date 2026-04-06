require_relative '../../test_helper'
require_relative '../../../lib/soren/types/request/body'

module Soren
  module Types
    module Request
      class BodyTest < Minitest::Test
        def test_stores_valid_string
          body = Body.new('{"name":"Alice"}')

          assert_equal '{"name":"Alice"}', body.to_s
        end

        def test_accepts_empty_string
          body = Body.new('')

          assert_equal '', body.to_s
        end

        def test_to_http_returns_body_string
          body = Body.new('{"name":"Alice"}')

          assert_equal '{"name":"Alice"}', body.to_http
        end

        def test_to_http_returns_nil_for_nil_body
          body = Body.new(nil)

          assert_nil body.to_http
        end

        def test_accepts_nil
          body = Body.new(nil)

          assert_nil body.to_s
        end

        def test_rejects_integer
          error = assert_raises(Soren::Error::ArgumentError) { Body.new(123) }

          assert_equal 'body must be a String or nil', error.message
        end

        def test_rejects_hash
          error = assert_raises(Soren::Error::ArgumentError) { Body.new({ key: 'value' }) }

          assert_equal 'body must be a String or nil', error.message
        end
      end
    end
  end
end
