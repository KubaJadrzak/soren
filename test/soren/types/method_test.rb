require_relative '../../test_helper'
require_relative '../../../lib/soren/types/request/method'

module Soren
  module Types
    module Request
      class MethodTest < Minitest::Test
        def test_accepts_get
          method = Method.new('get')

          assert_equal 'get', method.to_s
        end

        def test_accepts_symbol
          method = Method.new(:patch)

          assert_equal 'patch', method.to_s
        end

        def test_accepts_uppercase_post
          method = Method.new('POST')

          assert_equal 'post', method.to_s
        end

        def test_to_http_returns_uppercase_method
          method = Method.new(:patch)

          assert_equal 'PATCH', method.to_http
        end

        def test_accepts_put_patch_and_delete
          assert_equal 'put', Method.new('put').to_s
          assert_equal 'patch', Method.new('patch').to_s
          assert_equal 'delete', Method.new('delete').to_s
        end

        def test_rejects_non_string
          error = assert_raises(Soren::Error::ArgumentError) { Method.new(123) }

          assert_equal 'method must be a non-empty String or Symbol', error.message
        end

        def test_rejects_empty_string
          error = assert_raises(Soren::Error::ArgumentError) { Method.new('') }

          assert_equal 'method must be a non-empty String or Symbol', error.message
        end

        def test_rejects_unsupported_method
          error = assert_raises(Soren::Error::ArgumentError) { Method.new('options') }

          assert_equal 'method must be one of get, post, put, patch, delete', error.message
        end
      end
    end
  end
end
