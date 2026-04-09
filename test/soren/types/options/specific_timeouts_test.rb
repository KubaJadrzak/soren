require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/options/timeout/read_timeout'
require_relative '../../../../lib/soren/types/options/timeout/connect_timeout'
require_relative '../../../../lib/soren/types/options/timeout/write_timeout'

module Soren
  module Types
    module Options
      class SpecificTimeoutsTest < Minitest::Test
        def test_read_timeout_uses_default
          timeout = Timeout::ReadTimeout.new(nil)

          assert_equal Soren::Defaults::Options::READ_TIMEOUT, timeout.to_i
        end

        def test_connect_timeout_uses_default
          timeout = Timeout::ConnectTimeout.new(nil)

          assert_equal Soren::Defaults::Options::CONNECT_TIMEOUT, timeout.to_i
        end

        def test_write_timeout_uses_default
          timeout = Timeout::WriteTimeout.new(nil)

          assert_equal Soren::Defaults::Options::WRITE_TIMEOUT, timeout.to_i
        end

        def test_specific_timeout_accepts_explicit_value
          timeout = Timeout::ReadTimeout.new('1200')

          assert_equal 1200, timeout.to_i
        end
      end
    end
  end
end
