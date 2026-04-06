# typed: strict
# frozen_string_literal: true

require 'uri'

module Soren
  module Types
    module Connection
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

          if uri_host.blank? || uri_port.nil? || uri_scheme.blank?
            raise Soren::Error::ArgumentError, 'uri must include a host, port and scheme'
          end

          uri
        end
      end
    end
  end
end
