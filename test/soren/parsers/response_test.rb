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
    end
  end
end
