require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/config/timeout/base'

module Soren
  module Types
    module Config
      class TimeoutTest < Minitest::Test
        def test_accepts_integer_timeout
          timeout = Timeout::Base.new(10)

          assert_equal 10, timeout.to_i
        end

        def test_accepts_string_integer_timeout
          timeout = Timeout::Base.new('25')

          assert_equal 25, timeout.to_i
        end

        def test_accepts_zero_timeout
          timeout = Timeout::Base.new(0)

          assert_equal 0, timeout.to_i
        end

        def test_uses_default_when_timeout_is_nil
          timeout = Timeout::Base.new(nil, default: 15)

          assert_equal 15, timeout.to_i
        end

        def test_uses_default_when_timeout_is_blank_string
          timeout = Timeout::Base.new(' ', default: 20)

          assert_equal 20, timeout.to_i
        end

        def test_rejects_non_integer_timeout
          error = assert_raises(Soren::Error::ArgumentError) { Timeout::Base.new(1.5) }

          assert_equal 'timeout must be an integer', error.message
        end

        def test_rejects_non_numeric_string_timeout
          error = assert_raises(Soren::Error::ArgumentError) { Timeout::Base.new('abc') }

          assert_equal 'timeout must be an integer', error.message
        end

        def test_rejects_negative_timeout
          error = assert_raises(Soren::Error::ArgumentError) { Timeout::Base.new(-1) }

          assert_equal 'timeout must be greater than or equal to 0', error.message
        end
      end
    end
  end
end
