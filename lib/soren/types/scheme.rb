# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    class Scheme
      #: (untyped) -> void
      def initialize(scheme)
        @scheme = validate(scheme) #: String
      end

      #: -> String
      def to_s
        @scheme
      end

      #: -> bool
      def https?
        @scheme == 'https'
      end

      private

      #: (untyped) -> String
      def validate(scheme)
        unless scheme.is_a?(String) && !scheme.blank?
          raise Soren::Error::ArgumentError, 'scheme must be a non-empty String'
        end

        scheme_lower = scheme.downcase
        unless %w[http https].include?(scheme_lower)
          raise Soren::Error::ArgumentError, 'scheme must be either http or https'
        end

        scheme_lower
      end
    end
  end
end
