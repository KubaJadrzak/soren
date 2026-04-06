# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    class Headers
      #: (untyped) -> void
      def initialize(headers)
        @headers = validate(headers) #: Hash[untyped, untyped]
      end

      #: -> Hash[untyped, untyped]
      def to_h
        @headers
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
