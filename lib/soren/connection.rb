# typed: strict
# frozen_string_literal: true

require 'socket'
require 'openssl'
require 'timeout'

require_relative 'types/connection/host'
require_relative 'types/connection/port'
require_relative 'types/connection/scheme'
require_relative 'types/connection/uri'
require_relative 'options'
require_relative 'deadline'
require_relative 'response'
require_relative 'socket_io'

module Soren
  class Connection
    attr_reader :options #: Soren::Options?

    #: (?host: untyped, ?port: untyped, ?scheme: untyped, ?uri: untyped, ?options: untyped) -> void
    def initialize(host: nil, port: nil, scheme: nil, uri: nil, options: {})
      host, port, scheme = resolve_connection_parts(host: host, port: port, scheme: scheme, uri: uri)

      @host = Soren::Types::Connection::Host.new(host) #: Soren::Types::Connection::Host
      @port = Soren::Types::Connection::Port.new(port) #: Soren::Types::Connection::Port
      @scheme = Soren::Types::Connection::Scheme.new(scheme) #: Soren::Types::Connection::Scheme
      @options = Soren::Options.new(options) #: Soren::Options
    end

    #: -> (TCPSocket | OpenSSL::SSL::SSLSocket)
    def open_socket
      tcp = TCPSocket.new(@host.to_s, @port.to_i, connection_timeout: @options.connect_timeout)

      return tcp unless @scheme.https?

      ctx = OpenSSL::SSL::SSLContext.new
      ssl = OpenSSL::SSL::SSLSocket.new(tcp, ctx)
      ssl.hostname = @host.to_s
      ssl.connect
      ssl
    rescue Timeout::Error, Errno::ETIMEDOUT => e
      tcp&.close
      raise Soren::Error::TimeoutError, "connection timeout: #{e.message}"
    rescue OpenSSL::SSL::SSLError => e
      tcp&.close
      raise Soren::Error::SSLError, "SSL error: #{e.message}"
    rescue ::SocketError => e
      tcp&.close
      raise Soren::Error::DNSFailure, "DNS lookup failed: #{e.message}"
    rescue Errno::ECONNREFUSED => e
      tcp&.close
      raise Soren::Error::ConnectionRefused, "connection refused: #{e.message}"
    rescue SystemCallError, IOError => e
      tcp&.close
      raise Soren::Error::ConnectionError, "connection error: #{e.message}"
    end

    #: (Soren::Request) -> Soren::Response
    def send(request)
      socket = open_socket
      io = Soren::SocketIO.new(socket, request, @options, host: @host)
      io.write_request
      io.read_response
    rescue Timeout::Error, Errno::ETIMEDOUT => e
      raise Soren::Error::TimeoutError, "connection timeout: #{e.message}"
    rescue SystemCallError, IOError => e
      raise Soren::Error::ReadError, "read error: #{e.message}"
    ensure
      socket&.close
    end

    private

    #: (host: untyped, port: untyped, scheme: untyped, uri: untyped) -> [untyped, untyped, untyped]
    def resolve_connection_parts(host:, port:, scheme:, uri:)
      if uri.nil?
        [host, port, scheme]
      else
        unless host.nil? && port.nil? && scheme.nil?
          raise Soren::Error::ArgumentError,
                'pass either uri: or host:, port:, and scheme:, not both'
        end

        parsed_uri = Soren::Types::Connection::Uri.new(uri)
        [parsed_uri.host, parsed_uri.port, parsed_uri.scheme]
      end
    end
  end

end
