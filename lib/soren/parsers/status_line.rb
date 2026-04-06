# typed: strict
# frozen_string_literal: true

module Soren
  module Parsers
    class StatusLine
      #: (untyped) -> void
      def initialize(status_line)
        @status_line = status_line #: untyped
      end

      #: -> Hash[Symbol, untyped]
      def parse
        status_line_match = @status_line&.match(%r{\A(HTTP/\d+\.\d+)\s+(\d{3})(?:\s+(.*))?\z})
        unless status_line_match
          raise Soren::Error::ArgumentError, 'invalid HTTP status line'
        end

        version = status_line_match[1]
        status_code_text = status_line_match[2]
        status_message = status_line_match[3]&.strip

        if version.blank? || status_code_text.blank? || status_message.blank?
          raise Soren::Error::ArgumentError, 'status line must include version, status_code and status_message'
        end

        {
          version:        version,
          status_code:    Integer(status_code_text),
          status_message: status_message,
        }
      end
    end
  end
end
