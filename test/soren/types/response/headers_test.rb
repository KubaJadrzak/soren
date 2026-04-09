# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/response/headers'

module Soren
  module Types
    module Response
      class HeadersTest < Minitest::Test
        def test_accepts_valid_hash_with_array_values
          headers = Headers.new({ 'Content-Type' => ['application/json'] })

          assert_equal({ 'content-type' => ['application/json'] }, headers.to_h)
        end

        def test_get_all_returns_all_values_for_key
          headers = Headers.new({ 'Set-Cookie' => ['a=1', 'b=2'] })

          assert_equal ['a=1', 'b=2'], headers.get_all('set-cookie')
        end

        def test_get_all_returns_empty_array_for_missing_key
          headers = Headers.new({ 'content-type' => ['application/json'] })

          assert_equal [], headers.get_all('x-missing')
        end

        def test_content_length_returns_integer
          headers = Headers.new({ 'content-length' => ['42'] })

          assert_equal 42, headers.content_length
        end

        def test_content_length_returns_nil_for_invalid_value
          headers = Headers.new({ 'content-length' => ['abc'] })

          assert_nil headers.content_length
        end

        def test_chunked_is_true_when_transfer_encoding_contains_chunked
          headers = Headers.new({ 'transfer-encoding' => ['gzip, chunked'] })

          assert_equal true, headers.chunked?
        end

        def test_chunked_is_false_when_chunked_not_present
          headers = Headers.new({ 'transfer-encoding' => ['gzip'] })

          assert_equal false, headers.chunked?
        end

        def test_keep_alive_is_true_when_connection_contains_keep_alive
          headers = Headers.new({ 'connection' => ['upgrade, keep-alive'] })

          assert_equal true, headers.keep_alive?
        end

        def test_keep_alive_is_false_when_keep_alive_not_present
          headers = Headers.new({ 'connection' => ['close'] })

          assert_equal false, headers.keep_alive?
        end

        def test_content_encodings_parses_and_normalizes_multiple_values
          headers = Headers.new({ 'Content-Encoding' => ['gzip, deflate', 'identity'] })

          assert_equal %w[gzip deflate], headers.content_encodings
        end

        def test_rejects_non_array_values
          error = assert_raises(Soren::Error::ParseError) { Headers.new({ 'content-length' => '10' }) }

          assert_equal 'headers must be a Hash[String, Array[String]]', error.message
        end

        def test_rejects_array_with_non_string_entries
          error = assert_raises(Soren::Error::ParseError) { Headers.new({ 'content-length' => [10] }) }

          assert_equal 'headers must be a Hash[String, Array[String]]', error.message
        end
      end
    end
  end
end
