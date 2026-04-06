require_relative '../../test_helper'
require 'uri'
require_relative '../../../lib/soren/types/uri'

module Soren
  module Types
    class UriTest < Minitest::Test
      def test_http_uri_exposes_host_port_and_scheme
        uri = Uri.new(URI('http://example.com:8080'))

        assert_equal 'example.com', uri.host
        assert_equal 8080, uri.port
        assert_equal 'http', uri.scheme
      end

      def test_https_uri_uses_default_port
        uri = Uri.new(URI('https://example.com/users'))

        assert_equal 'example.com', uri.host
        assert_equal 443, uri.port
        assert_equal 'https', uri.scheme
      end

      def test_rejects_non_uri_objects
        error = assert_raises(Soren::Error::ArgumentError) { Uri.new('https://example.com') }

        assert_equal 'uri must be a URI::HTTP or URI::HTTPS object', error.message
      end

      def test_rejects_uri_without_host
        error = assert_raises(Soren::Error::ArgumentError) { Uri.new(URI('https:///path-only')) }

        assert_equal 'uri must include a host', error.message
      end
    end
  end
end
