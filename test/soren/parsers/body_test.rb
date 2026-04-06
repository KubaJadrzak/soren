require_relative '../../test_helper'
require_relative '../../../lib/soren/parsers/body'
require_relative '../../../lib/soren/types/response/headers'
require 'stringio'
require 'zlib'

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

      def test_raises_for_keep_alive_without_length
        socket = StringIO.new('hello')
        headers = Soren::Types::Response::Headers.new({})

        error = assert_raises(Soren::Error::ProtocolError) do
          Body.new(socket: socket, headers: headers, status_code: 200).parse
        end

        assert_equal 'cannot determine body length with keep-alive', error.message
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

      def test_decodes_gzip_encoded_body
        plain_body = 'hello gzip'
        encoded_body = gzip(plain_body)
        socket = StringIO.new(encoded_body)
        headers = Soren::Types::Response::Headers.new({
                                                        'content-length'   => [encoded_body.bytesize.to_s],
                                                        'content-encoding' => ['gzip'],
                                                      })

        body = Body.new(socket: socket, headers: headers, status_code: 200).parse

        assert_equal plain_body, body
      end

      def test_decodes_deflate_encoded_body
        plain_body = 'hello deflate'
        encoded_body = Zlib::Deflate.deflate(plain_body)
        socket = StringIO.new(encoded_body)
        headers = Soren::Types::Response::Headers.new({
                                                        'content-length'   => [encoded_body.bytesize.to_s],
                                                        'content-encoding' => ['deflate'],
                                                      })

        body = Body.new(socket: socket, headers: headers, status_code: 200).parse

        assert_equal plain_body, body
      end

      def test_decodes_multiple_content_encodings_in_order
        plain_body = 'hello multiple encodings'
        deflated_body = Zlib::Deflate.deflate(plain_body)
        encoded_body = gzip(deflated_body)
        socket = StringIO.new(encoded_body)
        headers = Soren::Types::Response::Headers.new({
                                                        'content-length'   => [encoded_body.bytesize.to_s],
                                                        'content-encoding' => ['deflate, gzip'],
                                                      })

        body = Body.new(socket: socket, headers: headers, status_code: 200).parse

        assert_equal plain_body, body
      end

      def test_rejects_unsupported_content_encoding
        socket = StringIO.new('hello')
        headers = Soren::Types::Response::Headers.new({
                                                        'content-length'   => ['5'],
                                                        'content-encoding' => ['br'],
                                                      })

        error = assert_raises(Soren::Error::ProtocolError) do
          Body.new(socket: socket, headers: headers, status_code: 200).parse
        end

        assert_equal 'unsupported content-encoding: br', error.message
      end

      def test_rejects_invalid_gzip_body
        socket = StringIO.new('not-gzip')
        headers = Soren::Types::Response::Headers.new({
                                                        'content-length'   => ['8'],
                                                        'content-encoding' => ['gzip'],
                                                      })

        error = assert_raises(Soren::Error::ParseError) do
          Body.new(socket: socket, headers: headers, status_code: 200).parse
        end

        assert_equal 'invalid gzip encoded body', error.message
      end

      private

      def gzip(value)
        io = StringIO.new
        writer = Zlib::GzipWriter.new(io)
        writer.write(value)
        writer.close
        io.string
      end
    end
  end
end
