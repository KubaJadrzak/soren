# typed: strict
# frozen_string_literal: true

require 'io/wait'

require_relative 'deadline'
require_relative 'response'

module Soren
  class SocketIO
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
        rescue IO::WaitWritable
          writable = wait_writable(deadline&.remaining)
          raise Soren::Error::WriteTimeout unless writable
        end
      end

      total_written
    end

    #: -> Soren::Response
    def read_response
      Soren::Response.new(@socket)
    end

    private

    #: (Float?) -> bool
    def wait_writable(timeout)
      @socket.to_io.wait_writable(timeout)
    end
  end
end
