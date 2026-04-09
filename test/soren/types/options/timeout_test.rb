# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/options/timeout/base'

module Soren
  module Types
    module Options
      class TimeoutTest < Minitest::Test
        def test_accepts_float_timeout
          timeout = Timeout::Base.new(1.5)

          assert_equal 1.5, timeout.to_f
        end

        def test_accepts_string_float_timeout
          timeout = Timeout::Base.new('2.5')

          assert_equal 2.5, timeout.to_f
        end

        def test_accepts_integer_timeout_and_normalizes_to_float
          timeout = Timeout::Base.new(3)

          assert_equal 3.0, timeout.to_f
        end

        def test_uses_default_when_timeout_is_nil
          timeout = Timeout::Base.new(nil, default: 1.5)

          assert_equal 1.5, timeout.to_f
        end

        def test_uses_default_when_timeout_is_blank_string
          timeout = Timeout::Base.new(' ', default: 2.0)

          assert_equal 2.0, timeout.to_f
        end

        def test_rejects_non_numeric_string_timeout
          error = assert_raises(Soren::Error::ArgumentError) { Timeout::Base.new('abc') }

          assert_equal 'timeout must be a float', error.message
        end

        def test_rejects_negative_timeout
          error = assert_raises(Soren::Error::ArgumentError) { Timeout::Base.new(-1) }

          assert_equal 'timeout must be greater than or equal to 0', error.message
        end
      end
    end
  end
end
