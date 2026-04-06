require_relative '../../test_helper'
require_relative '../../../lib/soren/parsers/response'

module Soren
  module Parsers
    class ResponseTest < Minitest::Test
      def test_parses_response_into_status_line_headers_and_body
        raw_response = [
          'HTTP/1.1 200 OK',
          'Content-Type: text/plain',
          'Content-Length: 5',
          '',
          'hello',
        ].join("\r\n")

        parsed = Response.new(raw_response).parse

        assert_equal({ version: 'HTTP/1.1', status_code: 200, status_message: 'OK' }, parsed[:status_line])
        assert_instance_of Soren::Types::Response::Headers, parsed[:headers]
        assert_equal({ 'content-type' => ['text/plain'], 'content-length' => ['5'] }, parsed[:headers].to_h)
        assert_equal 'hello', parsed[:body]
      end

      def test_wraps_parser_errors_as_response_error
        error = assert_raises(Soren::Error::ResponseError) do
          Response.new("INVALID\r\n\r\n").parse
        end

        assert_equal 'invalid HTTP status line', error.message
      end

      def test_wraps_decoder_errors_as_response_error
        raw_response = [
          'HTTP/1.1 200 OK',
          'Content-Length: 5',
          'Content-Encoding: br',
          '',
          'hello',
        ].join("\r\n")

        error = assert_raises(Soren::Error::ResponseError) do
          Response.new(raw_response).parse
        end

        assert_equal 'unsupported content-encoding: br', error.message
      end
    end
  end
end
