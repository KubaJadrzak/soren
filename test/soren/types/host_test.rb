require 'minitest/autorun'
require 'resolv'
require_relative '../../../lib/soren/types/connection/host' # adjust path as needed

module Soren
  module Types
    module Connection
      class HostTest < Minitest::Test
        # Test valid hostname
        def test_valid_hostname
          host = Host.new('example.com')
          assert_equal 'example.com', host.to_s
        end

        # Test valid IPv4
        def test_valid_ipv4
          host = Host.new('8.8.8.8')
          assert_equal '8.8.8.8', host.to_s
        end

        # Test valid IPv6
        def test_valid_ipv6
          host = Host.new('2001:4860:4860::8888') # Google DNS IPv6
          assert_equal '2001:4860:4860::8888', host.to_s
        end

        # Test empty string
        def test_empty_string
          error = assert_raises(Soren::Error::ArgumentError) { Host.new('') }
          assert_match(/host must be a non-empty String/, error.message)
        end

        # Test whitespace string
        def test_whitespace_string
          error = assert_raises(Soren::Error::ArgumentError) { Host.new('   ') }
          assert_match(/host must be a non-empty String/, error.message)
        end

        # Test invalid format
        def test_invalid_format
          error = assert_raises(Soren::Error::ArgumentError) { Host.new('!invalid_host#') }
          assert_match(/invalid host/, error.message)
        end

        # Test unresolvable host
        def test_unresolvable_host
          # Use a host unlikely to exist
          error = assert_raises(Soren::Error::ArgumentError) { Host.new('no-such-host-1234.local') }
          assert_match(/host not resolvable/, error.message)
        end
      end
    end
  end
end
