# typed: strict
# frozen_string_literal: true

require_relative '../../decoders/gzip'
require_relative '../../decoders/deflate'
require_relative '../../socket/reader'

module Soren
  module Parsers
    class Response
      class Body
        NO_CONTENT_STATUS_CODE = 204
        NOT_MODIFIED_STATUS_CODE = 304

        #: (reader: Soren::Socket::Reader, headers: Soren::Types::Response::Headers, code: Integer) -> void
        def initialize(reader:, headers:, code:)
          @reader = reader #: Soren::Socket::Reader
          @headers = headers #: Soren::Types::Response::Headers
          @code = code #: Integer
        end

        #: -> String
        def parse
          return '' if no_body?

          raw_body = if @headers.chunked?
                       parse_chunked_body
                     else
                       content_length = @headers.content_length
                       if !content_length.nil?
                         @reader.read_exactly(content_length)
                       elsif @headers.keep_alive?
                         raise Soren::Error::ProtocolError, 'cannot determine body length with keep-alive'
                       else
                         @reader.read_all
                       end
                     end

          decode_content_encodings(raw_body)
        end

        private

        #: -> bool
        def no_body?
          [NO_CONTENT_STATUS_CODE, NOT_MODIFIED_STATUS_CODE].include?(@code)
        end

        #: (String) -> String
        def decode_content_encodings(body)
          decoded_body = body

          @headers.content_encodings.reverse_each do |encoding|
            decoded_body = case encoding
                           when 'gzip'
                             Soren::Decoders::Gzip.new(decoded_body).decode
                           when 'deflate'
                             Soren::Decoders::Deflate.new(decoded_body).decode
                           else
                             raise Soren::Error::ProtocolError, "unsupported content-encoding: #{encoding}"
                           end
          end

          decoded_body
        end

        #: -> String
        def parse_chunked_body
          body = +''

          loop do
            chunk_size_line = @reader.read_line_with_terminator("\r\n")
            break if chunk_size_line.nil?

            chunk_size_str = chunk_size_line.strip.split(';', 2).first
            break if chunk_size_str.nil?

            chunk_size = chunk_size_str.to_i(16)
            break if chunk_size.zero?

            body << @reader.read_exactly(chunk_size)
            @reader.read_exactly(2)
          end

          consume_chunked_trailers

          body
        end

        #: -> void
        def consume_chunked_trailers
          loop do
            line = @reader.read_line_with_terminator("\r\n")
            break if line.blank?
          end
        end
      end
    end
  end
end
