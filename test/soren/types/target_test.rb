require_relative '../../test_helper'
require_relative '../../../lib/soren/types/request/target'

module Soren
  module Types
    module Request
      class TargetTest < Minitest::Test
        def test_stores_path_only
          target = Target.new('/users')

          assert_equal '/users', target.to_s
        end

        def test_stores_path_with_query_string
          target = Target.new('/users?page=1&per_page=50')

          assert_equal '/users?page=1&per_page=50', target.to_s
        end

        def test_to_http_returns_target
          target = Target.new('/users?page=1&per_page=50')

          assert_equal '/users?page=1&per_page=50', target.to_http
        end

        def test_accepts_root
          target = Target.new('/')

          assert_equal '/', target.to_s
        end

        def test_accepts_root_with_query_string
          target = Target.new('/?foo=bar')

          assert_equal '/?foo=bar', target.to_s
        end

        def test_rejects_non_string
          error = assert_raises(Soren::Error::ArgumentError) { Target.new(123) }

          assert_equal 'target must be a non-empty String', error.message
        end

        def test_rejects_empty_string
          error = assert_raises(Soren::Error::ArgumentError) { Target.new('') }

          assert_equal 'target must be a non-empty String', error.message
        end

        def test_rejects_whitespace_only_string
          error = assert_raises(Soren::Error::ArgumentError) { Target.new('   ') }

          assert_equal 'target must be a non-empty String', error.message
        end

        def test_rejects_target_without_leading_slash
          error = assert_raises(Soren::Error::ArgumentError) { Target.new('users?page=1') }

          assert_equal 'target must start with /', error.message
        end
      end
    end
  end
end
