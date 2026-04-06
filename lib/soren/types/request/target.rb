# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Request
      class Target
        #: (untyped) -> void
        def initialize(target)
          @target = validate(target) #: String
        end

        #: -> String
        def to_s
          @target
        end

        #: -> String
        def to_http
          @target
        end

        private

        #: (untyped) -> String
        def validate(target)
          unless target.is_a?(String) && !target.blank?
            raise Soren::Error::ArgumentError, 'target must be a non-empty String'
          end

          unless target.start_with?('/')
            raise Soren::Error::ArgumentError, 'target must start with /'
          end

          target
        end
      end
    end
  end
end
