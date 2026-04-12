# typed: strict
# frozen_string_literal: true

module Soren
  module Parsers
    class Response
      class StatusLine
        #: (untyped) -> void
        def initialize(status_line)
          @status_line = status_line #: untyped
        end

        #: -> Hash[Symbol, untyped]
        def parse
          status_line_match = @status_line&.match(%r{\A(HTTP/\d+\.\d+)\s+(\d{3})(?:\s+(.*))?\z})
          unless status_line_match
            raise Soren::Error::ParseError, 'invalid HTTP status line'
          end

          version = status_line_match[1]
          status_text = status_line_match[2]
          message = status_line_match[3]&.strip

          if version.blank? || status_text.blank? || message.blank?
            raise Soren::Error::ParseError, 'status line must include version, code and message'
          end

          {
            version: version,
            code:    Integer(status_text),
            message: message,
          }
        end
      end
    end
  end
end
