# typed: strict
# frozen_string_literal: true

require 'stringio'

require_relative 'response/status_line'
require_relative 'response/headers'
require_relative 'response/body'
require_relative '../types/response/headers'
require_relative '../socket/reader'
require_relative '../deadline'

module Soren
  module Parsers
    class Response
      #: (untyped, ?deadline: Deadline?) -> void
      def initialize(source, deadline: nil)
        @source = source #: untyped
        @deadline = deadline #: Deadline?
      end

      #: -> Hash[Symbol, untyped]
      def parse
        reader = Soren::Socket::Reader.new(@source, deadline: @deadline)

        status_line = reader.read_line
        if status_line.blank?
          raise Soren::Error::ParseError, 'raw_response must be a non-empty String'
        end

        header_lines = read_header_lines(reader)
        parsed_status_line = Soren::Parsers::Response::StatusLine.new(status_line.strip).parse
        parsed_headers = Soren::Parsers::Response::Headers.new(header_lines).parse

        headers_object = Soren::Types::Response::Headers.new(parsed_headers)
        parsed_body = Soren::Parsers::Response::Body.new(
          reader:  reader,
          headers: headers_object,
          code:    parsed_status_line[:code],
        ).parse

        {
          status_line: parsed_status_line,
          headers:     headers_object,
          body:        parsed_body,
        }
      end

      private

      #: (Soren::Socket::Reader) -> Array[String]
      def read_header_lines(reader)
        header_lines = [] #: Array[String]

        loop do
          line = reader.read_line
          break if line.blank?

          header_lines << line.strip
        end

        header_lines
      end
    end
  end
end
