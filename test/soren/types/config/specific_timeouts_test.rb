require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/config/timeout/read_timeout'
require_relative '../../../../lib/soren/types/config/timeout/connect_timeout'
require_relative '../../../../lib/soren/types/config/timeout/write_timeout'

module Soren
  module Types
    module Config
      class SpecificTimeoutsTest < Minitest::Test
        def test_read_timeout_uses_default
          timeout = Timeout::ReadTimeout.new(nil)

          assert_equal Soren::Defaults::Config::READ_TIMEOUT, timeout.to_i
        end

        def test_connect_timeout_uses_default
          timeout = Timeout::ConnectTimeout.new(nil)

          assert_equal Soren::Defaults::Config::CONNECT_TIMEOUT, timeout.to_i
        end

        def test_write_timeout_uses_default
          timeout = Timeout::WriteTimeout.new(nil)

          assert_equal Soren::Defaults::Config::WRITE_TIMEOUT, timeout.to_i
        end

        def test_specific_timeout_accepts_explicit_value
          timeout = Timeout::ReadTimeout.new('12')

          assert_equal 12, timeout.to_i
        end
      end
    end
  end
end
