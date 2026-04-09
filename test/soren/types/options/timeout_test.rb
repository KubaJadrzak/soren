require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/options/timeout/base'

module Soren
  module Types
    module Options
      class TimeoutTest < Minitest::Test
        def test_accepts_integer_timeout
          timeout = Timeout::Base.new(1000)

          assert_equal 1000, timeout.to_i
        end

        def test_accepts_string_integer_timeout
          timeout = Timeout::Base.new('2500')

          assert_equal 2500, timeout.to_i
        end

        def test_rejects_timeout_below_minimum
          error = assert_raises(Soren::Error::ArgumentError) { Timeout::Base.new(3) }

          assert_equal 'timeout must be at least 100 milliseconds', error.message
        end

        def test_uses_default_when_timeout_is_nil
          timeout = Timeout::Base.new(nil, default: 1500)

          assert_equal 1500, timeout.to_i
        end

        def test_uses_default_when_timeout_is_blank_string
          timeout = Timeout::Base.new(' ', default: 2000)

          assert_equal 2000, timeout.to_i
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
