# frozen_string_literal: true

require_relative '../../test_helper'
require_relative '../../../lib/soren/parsers/response'

module Soren
  module Parsers
    class Response
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

          assert_instance_of Soren::Types::Response::Version, parsed[:status_line][:version]
          assert_equal 'HTTP/1.1', parsed[:status_line][:version].to_s
          assert_instance_of Soren::Types::Response::Code, parsed[:status_line][:code]
          assert_equal 200, parsed[:status_line][:code].to_i
          assert_instance_of Soren::Types::Response::Message, parsed[:status_line][:message]
          assert_equal 'OK', parsed[:status_line][:message].to_s
          assert_instance_of Soren::Types::Response::Headers, parsed[:headers]
          assert_equal({ 'content-type' => ['text/plain'], 'content-length' => ['5'] }, parsed[:headers].to_h)
          assert_instance_of Soren::Types::Response::Body, parsed[:body]
          assert_equal 'hello', parsed[:body].to_s
        end

        def test_raises_parse_error_for_invalid_status_line
          error = assert_raises(Soren::Error::ParseError) do
            Response.new("INVALID\r\n\r\n").parse
          end

          assert_equal 'invalid HTTP status line', error.message
        end

        def test_raises_protocol_error_for_unsupported_encoding
          raw_response = [
            'HTTP/1.1 200 OK',
            'Content-Length: 5',
            'Content-Encoding: br',
            '',
            'hello',
          ].join("\r\n")

          error = assert_raises(Soren::Error::ProtocolError) do
            Response.new(raw_response).parse
          end

          assert_equal 'unsupported content-encoding: br', error.message
        end
      end
    end
  end
end
