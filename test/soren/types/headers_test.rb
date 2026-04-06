require_relative '../../test_helper'
require_relative '../../../lib/soren/types/headers'

module Soren
  module Types
    class HeadersTest < Minitest::Test
      def test_stores_valid_hash
        headers = Headers.new({ 'Accept' => 'application/json' })

        assert_equal({ 'Accept' => 'application/json' }, headers.to_h)
      end

      def test_accepts_empty_hash
        headers = Headers.new({})

        assert_equal({}, headers.to_h)
      end

      def test_accepts_hash_with_multiple_headers
        headers = Headers.new({ 'Accept' => 'application/json', 'Authorization' => 'Bearer token' })

        assert_equal({ 'Accept' => 'application/json', 'Authorization' => 'Bearer token' }, headers.to_h)
      end

      def test_rejects_string
        error = assert_raises(Soren::Error::ArgumentError) { Headers.new('Accept: application/json') }

        assert_equal 'headers must be a Hash', error.message
      end

      def test_rejects_nil
        error = assert_raises(Soren::Error::ArgumentError) { Headers.new(nil) }

        assert_equal 'headers must be a Hash', error.message
      end

      def test_rejects_array
        error = assert_raises(Soren::Error::ArgumentError) { Headers.new([['Accept', 'application/json']]) }

        assert_equal 'headers must be a Hash', error.message
      end
    end
  end
end
