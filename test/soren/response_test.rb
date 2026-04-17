# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/soren/response'
require_relative '../../lib/soren/parsers/response'

module Soren
  class ResponseTest < Minitest::Test
    def test_parses_version_status_headers_and_body
      raw_response = [
        'HTTP/1.1 404 Not Found',
        'Content-Type: text/plain',
        'Content-Length: 9',
        '',
        'not found',
      ].join("\r\n")

      response = build_response(raw_response)

      assert_equal 'HTTP/1.1', response.version
      assert_equal 404, response.code
      assert_equal 'Not Found', response.message
      assert_equal({ 'content-type' => ['text/plain'], 'content-length' => ['9'] }, response.headers)
      assert_equal 'not found', response.body
    end

    def test_merges_duplicate_headers_into_arrays
      raw_response = [
        'HTTP/1.1 200 OK',
        'Set-Cookie: a=1',
        'set-cookie: b=2',
        'Content-Length: 0',
        '',
        '',
      ].join("\r\n")

      response = build_response(raw_response)

      assert_equal({ 'set-cookie' => ['a=1', 'b=2'], 'content-length' => ['0'] }, response.headers)
    end

    def test_rejects_invalid_status_line
      error = assert_raises(Soren::Error::ParseError) do
        build_response("INVALID\r\n\r\n")
      end

      assert_equal 'invalid HTTP status line', error.message
    end

    def test_rejects_invalid_header_line
      error = assert_raises(Soren::Error::ParseError) do
        build_response("HTTP/1.1 200 OK\r\nInvalidHeader\r\n\r\n")
      end

      assert_equal 'invalid HTTP header line', error.message
    end

    def test_accepts_status_line_without_reason_phrase
      response = build_response("HTTP/1.1 200\r\nContent-Length: 0\r\n\r\n")

      assert_equal 200, response.code
      assert_equal '', response.message
    end

    private

    def build_response(raw_response)
      parsed_response = Soren::Parsers::Response.new(raw_response).parse
      Response.new(parsed_response)
    end
  end
end
