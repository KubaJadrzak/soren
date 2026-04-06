# typed: strict
# frozen_string_literal: true

require 'uri'

module Soren
  module Types
    class Uri
      #: (untyped) -> void
      def initialize(uri)
        @uri = validate(uri) #: URI::HTTP
      end

      #: -> String
      def host
        host = @uri.host
        raise Soren::Error::ArgumentError, 'uri must include a host' if host.nil?

        host
      end

      #: -> Integer
      def port
        port = @uri.port
        raise Soren::Error::ArgumentError, 'uri must include a port' if port.nil?

        port
      end

      #: -> String
      def scheme
        scheme = @uri.scheme
        raise Soren::Error::ArgumentError, 'uri must include a scheme' if scheme.nil?

        scheme
      end

      private

      #: (untyped) -> URI::HTTP
      def validate(uri)
        unless uri.is_a?(URI::HTTP)
          raise Soren::Error::ArgumentError, 'uri must be a URI::HTTP or URI::HTTPS object'
        end

        uri
      end
    end
  end
end
