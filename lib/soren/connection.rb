# typed: strict
# frozen_string_literal: true

require 'socket'
require 'openssl'

require_relative 'types/connection/host'
require_relative 'types/connection/port'
require_relative 'types/connection/scheme'
require_relative 'types/connection/uri'
require_relative 'response'

module Soren
  class Connection
    #: (?host: untyped, ?port: untyped, ?scheme: untyped, ?uri: untyped) -> void
    def initialize(host: nil, port: nil, scheme: nil, uri: nil)
      if uri
        unless host.nil? && port.nil? && scheme.nil?
          raise Soren::Error::ArgumentError,
                'pass either uri: or host:, port:, and scheme:, not both'
        end

        parsed_uri = Soren::Types::Connection::Uri.new(uri)
        host = parsed_uri.host
        port = parsed_uri.port
        scheme = parsed_uri.scheme
      elsif host.nil? || port.nil? || scheme.nil?
        raise Soren::Error::ArgumentError,
              'host, port, and scheme are required when uri is not provided'
      end

      @host = Soren::Types::Connection::Host.new(host) #: Soren::Types::Connection::Host
      @port = Soren::Types::Connection::Port.new(port) #: Soren::Types::Connection::Port
      @scheme = Soren::Types::Connection::Scheme.new(scheme) #: Soren::Types::Connection::Scheme
    end

    #: -> (TCPSocket | OpenSSL::SSL::SSLSocket)
    def open_socket
      tcp = TCPSocket.new(@host.to_s, @port.to_i)

      return tcp unless @scheme.https?

      ctx = OpenSSL::SSL::SSLContext.new
      ssl = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
      ssl.hostname = @host.to_s
      ssl.connect
      ssl
    end

    #: (Soren::Request) -> Soren::Response
    def send(request)
      socket = open_socket
      socket.write(request.to_http(host: @host.to_s))

      Soren::Response.new(socket)
    ensure
      socket&.close
    end
  end

end
