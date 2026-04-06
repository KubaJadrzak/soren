# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    class Body
      #: (untyped) -> void
      def initialize(body)
        @body = validate(body) #: String?
      end

      #: -> String?
      def to_s
        @body
      end

      private

      #: (untyped) -> String?
      def validate(body)
        return if body.nil?

        unless body.is_a?(String)
          raise Soren::Error::ArgumentError, 'body must be a String or nil'
        end

        body
      end
    end
  end
end
