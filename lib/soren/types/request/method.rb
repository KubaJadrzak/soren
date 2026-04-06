# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Request
      class Method
        ALLOWED_METHODS = %w[get post put patch delete].freeze

        #: (untyped) -> void
        def initialize(method)
          @method = validate(method) #: String
        end

        #: -> String
        def to_s
          @method
        end

        #: -> String
        def to_http
          @method.upcase
        end

        private

        #: (untyped) -> String
        def validate(method)
          unless method.is_a?(String) || method.is_a?(Symbol)
            raise Soren::Error::ArgumentError, 'method must be a non-empty String or Symbol'
          end

          normalized_method = method.to_s.downcase

          if normalized_method.blank?
            raise Soren::Error::ArgumentError, 'method must be a non-empty String or Symbol'
          end

          unless ALLOWED_METHODS.include?(normalized_method)
            raise Soren::Error::ArgumentError, 'method must be one of get, post, put, patch, delete'
          end

          normalized_method
        end
      end
    end
  end
end
