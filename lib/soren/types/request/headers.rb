# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Request
      class Headers
        #: (untyped, ?content_length: Integer?) -> void
        def initialize(headers, content_length: nil)
          @headers = validate(headers, content_length:) #: Hash[String, String]
        end

        #: -> Hash[String, String]
        def to_h
          @headers
        end

        #: (host: untyped) -> Array[String]
        def to_http(host:)
          unless host.is_a?(String) && !host.blank?
            raise Soren::Error::ArgumentError, 'host must be a non-empty String'
          end

          request_headers = @headers.dup
          unless request_headers.keys.any? { |key| key.casecmp?('host') }
            request_headers['Host'] = host
          end

          request_headers.map { |key, value| "#{key}: #{value}" }
        end

        private

        #: (untyped, content_length: Integer?) -> Hash[String, String]
        def validate(headers, content_length:)
          unless headers.is_a?(Hash)
            raise Soren::Error::ArgumentError, 'headers must be a Hash'
          end

          unless headers.all? { |k, v| k.is_a?(String) && v.is_a?(String) }
            raise Soren::Error::ArgumentError, 'header keys and values must be Strings'
          end

          if !content_length.nil? &&
             headers.keys.none? { |key| key.casecmp?('content-length') }

            return headers.merge('Content-Length' => content_length.to_s)
          end

          headers
        end
      end
    end
  end
end
