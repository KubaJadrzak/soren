# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/soren/response'

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

      response = Response.new(raw_response)

      assert_equal 'HTTP/1.1', response.version.to_s
      assert_equal 404, response.status_code.to_i
      assert_equal 'Not Found', response.status_message.to_s
      assert_equal({ 'content-type' => ['text/plain'], 'content-length' => ['9'] }, response.headers.to_h)
      assert_equal 'not found', response.body.to_s
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

      response = Response.new(raw_response)

      assert_equal({ 'set-cookie' => ['a=1', 'b=2'], 'content-length' => ['0'] }, response.headers.to_h)
    end

    def test_rejects_invalid_status_line
      error = assert_raises(Soren::Error::ParseError) do
        Response.new("INVALID\r\n\r\n")
      end

      assert_equal 'invalid HTTP status line', error.message
    end

    def test_rejects_invalid_header_line
      error = assert_raises(Soren::Error::ParseError) do
        Response.new("HTTP/1.1 200 OK\r\nInvalidHeader\r\n\r\n")
      end

      assert_equal 'invalid HTTP header line', error.message
    end

    def test_rejects_status_line_with_missing_status_message
      error = assert_raises(Soren::Error::ParseError) do
        Response.new("HTTP/1.1 200    \r\n\r\n")
      end

      assert_equal 'status line must include version, status_code and status_message', error.message
    end
  end
end
