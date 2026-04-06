require_relative '../../test_helper'
require_relative '../../../lib/soren/types/connection/port'

module Soren
  module Types
    module Connection
      class PortTest < Minitest::Test
        # Test valid integer port
        def test_valid_integer_port
          port = Port.new(8080)
          assert_equal '8080', port.to_s
          assert_equal 8080, port.to_i
        end

        # Test valid string port
        def test_valid_string_port
          port = Port.new('443')
          assert_equal '443', port.to_s
          assert_equal 443, port.to_i
        end

        # Test minimum valid port (1)
        def test_minimum_port
          port = Port.new(1)
          assert_equal '1', port.to_s
          assert_equal 1, port.to_i
        end

        # Test maximum valid port (65535)
        def test_maximum_port
          port = Port.new(65535)
          assert_equal '65535', port.to_s
          assert_equal 65535, port.to_i
        end

        # Test port 80 (common HTTP)
        def test_common_http_port
          port = Port.new(80)
          assert_equal '80', port.to_s
          assert_equal 80, port.to_i
        end

        # Test port 443 (common HTTPS)
        def test_common_https_port
          port = Port.new(443)
          assert_equal '443', port.to_s
          assert_equal 443, port.to_i
        end

        # Test invalid type (not integer or convertible string)
        def test_invalid_type
          error = assert_raises(Soren::Error::ArgumentError) { Port.new([8080]) }
          assert_match(/port must be an integer/, error.message)
        end

        # Test invalid string (not convertible to integer)
        def test_invalid_string
          error = assert_raises(Soren::Error::ArgumentError) { Port.new('abc') }
          assert_match(/port must be a valid integer or string convertible to integer/, error.message)
        end

        # Test string with extra characters
        def test_string_with_extra_characters
          error = assert_raises(Soren::Error::ArgumentError) { Port.new('8080abc') }
          assert_match(/port must be a valid integer or string convertible to integer/, error.message)
        end

        # Test port below minimum (0)
        def test_port_below_minimum
          error = assert_raises(Soren::Error::ArgumentError) { Port.new(0) }
          assert_match(/port must be between 1 and 65535/, error.message)
        end

        # Test port above maximum (65536)
        def test_port_above_maximum
          error = assert_raises(Soren::Error::ArgumentError) { Port.new(65536) }
          assert_match(/port must be between 1 and 65535/, error.message)
        end

        # Test negative port
        def test_negative_port
          error = assert_raises(Soren::Error::ArgumentError) { Port.new(-1) }
          assert_match(/port must be between 1 and 65535/, error.message)
        end

        # Test float input (should be rejected)
        def test_float_input
          error = assert_raises(Soren::Error::ArgumentError) { Port.new(8080.5) }
          assert_match(/port must be an integer/, error.message)
        end
      end
    end
  end
end
