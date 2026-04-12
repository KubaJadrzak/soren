# typed: strict
# frozen_string_literal: true

require 'io/wait'

require_relative '../deadline'
require_relative '../parsers/response'

module Soren
  module Socket
    class IO
      #: ((TCPSocket | OpenSSL::SSL::SSLSocket), Soren::Request, Soren::Options, host: untyped) -> void
      def initialize(socket, request, options, host:)
        @socket = socket #: (TCPSocket | OpenSSL::SSL::SSLSocket)
        @request = request #: Soren::Request
        @options = options #: Soren::Options
        @host = host #: untyped
      end

      #: -> Integer
      def write_request
        data = @request.to_http(host: @host.to_s)
        total_written = 0

        deadline = Deadline.start(@options.write_timeout.to_f)

        while total_written < data.bytesize
          raise Soren::Error::WriteTimeout if deadline&.expired?

          begin
            written = @socket.write_nonblock(data.byteslice(total_written..))
            total_written += written
          rescue StandardError => e
            handle_write_error(e, deadline)
          end
        end

        total_written
      end

      #: -> Hash[Symbol, untyped]
      def read_response
        deadline = Deadline.start(@options.read_timeout.to_f)
        Soren::Parsers::Response.new(@socket, deadline: deadline).parse
      end

      private

      #: (StandardError, Deadline?) -> void
      def handle_write_error(error, deadline)
        return if error.class.to_s != 'IO::WaitWritable'

        writable = wait_writable(deadline&.remaining)
        raise Soren::Error::WriteTimeout unless writable
      end

      #: (Float?) -> bool
      def wait_writable(timeout)
        @socket.to_io.wait_writable(timeout)
      end
    end
  end
end
