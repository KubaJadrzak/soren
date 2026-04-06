# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Request
      class Headers
        #: (untyped) -> void
        def initialize(headers)
          @headers = validate(headers) #: Hash[untyped, untyped]
        end

        #: -> Hash[untyped, untyped]
        def to_h
          @headers
        end

        #: (host: untyped) -> Array[String]
        def to_http(host:)
          unless host.is_a?(String) && !host.blank?
            raise Soren::Error::ArgumentError, 'host must be a non-empty String'
          end

          request_headers = @headers.dup
          unless request_headers.keys.any? { |key| key.to_s.casecmp('host').zero? }
            request_headers['Host'] = host
          end

          request_headers.map { |key, value| "#{key}: #{value}" }
        end

        private

        #: (untyped) -> Hash[untyped, untyped]
        def validate(headers)
          unless headers.is_a?(Hash)
            raise Soren::Error::ArgumentError, 'headers must be a Hash'
          end

          headers
        end
      end
    end
  end
end
