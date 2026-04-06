# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Response
      class Headers
        #: (untyped) -> void
        def initialize(headers)
          @headers = validate(headers) #: Hash[String, Array[String]]
        end

        #: -> Hash[String, Array[String]]
        def to_h
          @headers
        end

        #: (untyped) -> Array[String]
        def get_all(key)
          return [] unless key.is_a?(String)

          @headers[key.downcase] || []
        end

        #: -> Integer?
        def content_length
          value = get_all('content-length').first
          return if value.blank?

          Integer(value)
        rescue ArgumentError
          nil
        end

        #: -> bool
        def chunked?
          split_header_values(get_all('transfer-encoding')).include?('chunked')
        end

        #: -> bool
        def keep_alive?
          values = split_header_values(get_all('connection'))

          return false if values.include?('close')
          return true if values.include?('keep-alive')

          true
        end

        private

        #: (untyped) -> Hash[String, Array[String]]
        def validate(headers)
          unless headers.is_a?(Hash)
            raise Soren::Error::ArgumentError, 'headers must be a Hash'
          end

          normalized_headers = {}
          headers.each do |key, value|
            unless key.is_a?(String) && value.is_a?(Array) && value.all? { |item| item.is_a?(String) }
              raise Soren::Error::ArgumentError, 'headers must be a Hash[String, Array[String]]'
            end

            normalized_key = key.downcase
            normalized_headers[normalized_key] ||= []
            normalized_headers[normalized_key].concat(value)
          end

          normalized_headers
        end

        #: (Array[String]) -> Array[String]
        def split_header_values(values)
          values.flat_map do |value|
            value.split(',').map { |v| v.strip.downcase }
          end
        end

      end
    end
  end
end
