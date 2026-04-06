# typed: strict
# frozen_string_literal: true

module Soren
  module Parsers
    class Headers
      #: (untyped) -> void
      def initialize(header_lines)
        @header_lines = header_lines #: untyped
      end

      #: -> Hash[String, Array[String]]
      def parse
        parsed_headers = {} #: Hash[String, Array[String]]

        Array(@header_lines).each do |line|
          next if line.blank?

          key, value = line.split(':', 2)
          unless key && value
            raise Soren::Error::ParserError, 'invalid HTTP header line'
          end

          normalized_key = key.strip.downcase
          values = (parsed_headers[normalized_key] ||= [])
          values << value.strip
        end

        parsed_headers
      end
    end
  end
end
