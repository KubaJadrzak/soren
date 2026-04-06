require_relative '../../test_helper'
require_relative '../../../lib/soren/types/connection/scheme'

module Soren
  module Types
    module Connection
      class SchemeTest < Minitest::Test
        # Test valid http scheme
        def test_valid_http_scheme
          scheme = Scheme.new('http')
          assert_equal 'http', scheme.to_s
        end

        # Test valid https scheme
        def test_valid_https_scheme
          scheme = Scheme.new('https')
          assert_equal 'https', scheme.to_s
        end

        # Test case insensitivity - uppercase HTTP
        def test_uppercase_http
          scheme = Scheme.new('HTTP')
          assert_equal 'http', scheme.to_s
        end

        # Test case insensitivity - uppercase HTTPS
        def test_uppercase_https
          scheme = Scheme.new('HTTPS')
          assert_equal 'https', scheme.to_s
        end

        # Test case insensitivity - mixed case Http
        def test_mixed_case_http
          scheme = Scheme.new('Http')
          assert_equal 'http', scheme.to_s
        end

        # Test case insensitivity - mixed case Https
        def test_mixed_case_https
          scheme = Scheme.new('Https')
          assert_equal 'https', scheme.to_s
        end

        # Test invalid scheme - ftp
        def test_invalid_scheme_ftp
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new('ftp') }
          assert_match(/scheme must be either http or https/, error.message)
        end

        # Test invalid scheme - ws
        def test_invalid_scheme_ws
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new('ws') }
          assert_match(/scheme must be either http or https/, error.message)
        end

        # Test invalid scheme - custom
        def test_invalid_scheme_custom
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new('custom') }
          assert_match(/scheme must be either http or https/, error.message)
        end

        # Test empty string
        def test_empty_string
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new('') }
          assert_match(/scheme must be a non-empty String/, error.message)
        end

        # Test whitespace only string
        def test_whitespace_only_string
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new('   ') }
          assert_match(/scheme must be a non-empty String/, error.message)
        end

        # Test non-string type - integer
        def test_non_string_integer
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new(80) }
          assert_match(/scheme must be a non-empty String/, error.message)
        end

        # Test non-string type - array
        def test_non_string_array
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new(['http']) }
          assert_match(/scheme must be a non-empty String/, error.message)
        end

        # Test non-string type - nil
        def test_non_string_nil
          error = assert_raises(Soren::Error::ArgumentError) { Scheme.new(nil) }
          assert_match(/scheme must be a non-empty String/, error.message)
        end
      end
    end
  end
end
