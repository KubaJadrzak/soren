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

      #: -> String?
      def host
        @uri.host
      end

      #: -> Integer?
      def port
        @uri.port
      end

      #: -> String?
      def scheme
        @uri.scheme
      end

      private

      #: (untyped) -> URI::HTTP
      def validate(uri)
        unless uri.is_a?(URI::HTTP)
          raise Soren::Error::ArgumentError, 'uri must be a URI::HTTP or URI::HTTPS object'
        end

        uri_host = uri.host
        uri_port = uri.port
        uri_scheme = uri.scheme

        if uri_host.nil? || uri_host.strip.empty? || uri_port.nil? || uri_scheme.nil? || uri_scheme.strip.empty?
          raise Soren::Error::ArgumentError, 'uri must include a host, port and scheme'
        end

        uri
      end
    end
  end
end
