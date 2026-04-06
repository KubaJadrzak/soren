require_relative '../../test_helper'
require_relative '../../../lib/soren/parsers/body'
require_relative '../../../lib/soren/types/response/headers'
require 'stringio'

module Soren
  module Parsers
    class BodyTest < Minitest::Test
      def test_reads_body_using_content_length
        socket = StringIO.new('helloTRAILING')
        headers = Soren::Types::Response::Headers.new({ 'content-length' => ['5'] })

        body = Body.new(socket: socket, headers: headers, status_code: 200).parse

        assert_equal 'hello', body
      end

      def test_reads_chunked_body
        socket = StringIO.new("5\r\nhello\r\n6\r\n world\r\n0\r\n\r\n")
        headers = Soren::Types::Response::Headers.new({ 'transfer-encoding' => ['chunked'] })

        body = Body.new(socket: socket, headers: headers, status_code: 200).parse

        assert_equal 'hello world', body
      end

      def test_reads_until_socket_close_when_connection_is_close_and_no_length
        socket = StringIO.new('hello until close')
        headers = Soren::Types::Response::Headers.new({ 'connection' => ['close'] })

        body = Body.new(socket: socket, headers: headers, status_code: 200).parse

        assert_equal 'hello until close', body
      end

      def test_returns_empty_body_for_keep_alive_without_length
        socket = StringIO.new('hello')
        headers = Soren::Types::Response::Headers.new({})

        body = Body.new(socket: socket, headers: headers, status_code: 200).parse

        assert_equal '', body
      end

      def test_returns_empty_body_for_status_204
        socket = StringIO.new('should be ignored')
        headers = Soren::Types::Response::Headers.new({ 'content-length' => ['17'] })

        body = Body.new(socket: socket, headers: headers, status_code: 204).parse

        assert_equal '', body
      end

      def test_returns_empty_body_for_status_304
        socket = StringIO.new('should be ignored')
        headers = Soren::Types::Response::Headers.new({ 'content-length' => ['17'] })

        body = Body.new(socket: socket, headers: headers, status_code: 304).parse

        assert_equal '', body
      end
    end
  end
end
