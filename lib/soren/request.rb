# typed: strict
# frozen_string_literal: true

require_relative 'types/host'
require_relative 'types/port'
require_relative 'types/scheme'
require_relative 'types/uri'

module Soren
  class Request
    #: (?host: untyped, ?port: untyped, ?scheme: untyped, ?uri: untyped) -> void
    def initialize(host: nil, port: nil, scheme: nil, uri: nil)
      if uri
        unless host.nil? && port.nil? && scheme.nil?
          raise Soren::Error::ArgumentError,
                'pass either uri: or host:, port:, and scheme:, not both'
        end

        parsed_uri = Soren::Types::Uri.new(uri)
        host = parsed_uri.host
        port = parsed_uri.port
        scheme = parsed_uri.scheme
      elsif host.nil? || port.nil? || scheme.nil?
        raise Soren::Error::ArgumentError,
              'host, port, and scheme are required when uri is not provided'
      end

      @host = Soren::Types::Host.new(host) #: Soren::Types::Host
      @port = Soren::Types::Port.new(port) #: Soren::Types::Port
      @scheme = Soren::Types::Scheme.new(scheme) #: Soren::Types::Scheme
    end
  end
end
