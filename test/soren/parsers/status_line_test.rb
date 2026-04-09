# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/soren/parsers/status_line'

module Soren
  module Parsers
    class StatusLineTest < Minitest::Test
      def test_parses_status_line
        parsed = StatusLine.new('HTTP/1.1 201 Created').parse

        assert_equal({ version: 'HTTP/1.1', status_code: 201, status_message: 'Created' }, parsed)
      end

      def test_rejects_invalid_status_line
        error = assert_raises(Soren::Error::ParseError) { StatusLine.new('INVALID').parse }

        assert_equal 'invalid HTTP status line', error.message
      end
    end
  end
end
