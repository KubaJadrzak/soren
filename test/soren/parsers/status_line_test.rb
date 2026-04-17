# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/soren/parsers/response/status_line'

module Soren
  module Parsers
    class Response
      class StatusLineTest < Minitest::Test
        def test_parses_status_line
          parsed = Soren::Parsers::Response::StatusLine.new('HTTP/1.1 201 Created').parse

          assert_equal({ version: 'HTTP/1.1', code: 201, message: 'Created' }, parsed)
        end

        def test_parses_status_line_without_reason_phrase
          parsed = Soren::Parsers::Response::StatusLine.new('HTTP/1.1 200').parse

          assert_equal({ version: 'HTTP/1.1', code: 200, message: '' }, parsed)
        end

        def test_rejects_invalid_status_line
          error = assert_raises(Soren::Error::ParseError) { Soren::Parsers::Response::StatusLine.new('INVALID').parse }

          assert_equal 'invalid HTTP status line', error.message
        end
      end
    end
  end
end
