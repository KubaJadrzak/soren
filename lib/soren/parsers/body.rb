# typed: strict
# frozen_string_literal: true

module Soren
  module Parsers
    class Body
      #: (socket: untyped, headers: Soren::Types::Response::Headers, status_code: Integer) -> void
      def initialize(socket:, headers:, status_code:)
        @socket = socket #: untyped
        @headers = headers #: Soren::Types::Response::Headers
        @status_code = status_code #: Integer
      end

      #: -> String
      def parse
        return '' if [204, 304].include?(@status_code)

        return parse_chunked_body if @headers.chunked?

        content_length = @headers.content_length
        return read_exactly(content_length) unless content_length.nil?

        return '' if @headers.keep_alive?

        @socket.read.to_s
      end

      private

      #: -> String
      def parse_chunked_body
        body = +''

        loop do
          chunk_size_line = @socket.gets
          break if chunk_size_line.nil?

          chunk_size = chunk_size_line.strip.split(';', 2).first.to_i(16)
          break if chunk_size.zero?

          body << read_exactly(chunk_size)
          @socket.read(2)
        end

        consume_chunked_trailers

        body
      end

      #: -> void
      def consume_chunked_trailers
        loop do
          line = @socket.gets
          break if line.nil? || line.strip.empty?
        end
      end

      #: (Integer) -> String
      def read_exactly(length)
        return '' if length <= 0

        @socket.read(length).to_s
      end
    end
  end
end
