# typed: strict
# frozen_string_literal: true

require 'stringio'

require_relative 'status_line'
require_relative 'headers'
require_relative 'body'
require_relative '../types/response/headers'

module Soren
  module Parsers
    class Response
      #: (untyped) -> void
      def initialize(source)
        @source = source #: untyped
      end

      #: -> Hash[Symbol, untyped]
      def parse
        io = to_io(@source)

        status_line = io.gets
        if status_line.nil? || status_line.blank?
          raise Soren::Error::ArgumentError, 'raw_response must be a non-empty String'
        end

        header_lines = read_header_lines(io)
        parsed_status_line = Soren::Parsers::StatusLine.new(status_line.strip).parse
        parsed_headers = Soren::Parsers::Headers.new(header_lines).parse

        headers_object = Soren::Types::Response::Headers.new(parsed_headers)
        parsed_body = Soren::Parsers::Body.new(
          socket:      io,
          headers:     headers_object,
          status_code: parsed_status_line[:status_code],
        ).parse

        {
          status_line: parsed_status_line,
          headers:     headers_object,
          body:        parsed_body,
        }
      end

      private

      #: (untyped) -> untyped
      def to_io(source)
        return source if source.respond_to?(:gets) && source.respond_to?(:read)

        if source.is_a?(String)
          return StringIO.new(source)
        end

        raise Soren::Error::ArgumentError, 'raw_response must be a non-empty String'
      end

      #: (untyped) -> Array[String]
      def read_header_lines(io)
        header_lines = [] #: Array[String]

        loop do
          line = io.gets
          break if line.nil? || line.strip.empty?

          header_lines << line.strip
        end

        header_lines
      end
    end
  end
end
