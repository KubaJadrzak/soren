# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/soren/parsers/headers'

module Soren
  module Parsers
    class HeadersTest < Minitest::Test
      def test_parses_and_normalizes_headers
        lines = [
          'Content-Type: text/plain',
          'Set-Cookie: a=1',
          'set-cookie: b=2',
        ]

        parsed = Headers.new(lines).parse

        assert_equal({ 'content-type' => ['text/plain'], 'set-cookie' => ['a=1', 'b=2'] }, parsed)
      end

      def test_rejects_invalid_header_line
        error = assert_raises(Soren::Error::ParseError) { Headers.new(['InvalidHeader']).parse }

        assert_equal 'invalid HTTP header line', error.message
      end
    end
  end
end
