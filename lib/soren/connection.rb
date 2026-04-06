# typed: strict
# frozen_string_literal: true

require 'socket'
require 'openssl'
require 'timeout'

require_relative 'types/connection/host'
require_relative 'types/connection/port'
require_relative 'types/connection/scheme'
require_relative 'types/connection/uri'
require_relative 'config'
require_relative 'response'

module Soren
  class Connection
    attr_reader :config #: Soren::Config?

    #: (?host: untyped, ?port: untyped, ?scheme: untyped, ?uri: untyped, ?config: untyped) -> void
    def initialize(host: nil, port: nil, scheme: nil, uri: nil, config: nil)
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
      @config = normalize_config(config) #: Soren::Config
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
      socket.write(request.to_http(host: @host.to_s))

      Soren::Response.new(socket)
    rescue Timeout::Error, Errno::ETIMEDOUT => e
      raise Soren::Error::TimeoutError, "connection timeout: #{e.message}"
    rescue SystemCallError, IOError => e
      raise Soren::Error::ReadError, "read error: #{e.message}"
    ensure
      socket&.close
    end

    private

    #: (untyped) -> Soren::Config
    def normalize_config(config)
      return Soren::Config.new if config.nil?

      unless config.is_a?(Soren::Config)
        raise Soren::Error::ArgumentError, 'config must be a Soren::Config'
      end

      config
    end
  end

end
