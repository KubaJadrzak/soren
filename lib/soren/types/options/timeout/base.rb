# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Options
      module Timeout
        class Base
          #: (Float | Integer | String | nil, ?default: Float?) -> void
          def initialize(timeout, default: nil)
            timeout = default if timeout.blank?
            @timeout = validate(timeout) #: Float
          end

          #: -> Float
          def to_f
            @timeout
          end

          private

          #: (Float | Integer | String | nil) -> Float
          def validate(timeout)
            if timeout.is_a?(String)
              begin
                timeout = Float(timeout)
              rescue ArgumentError
                raise Soren::Error::ArgumentError, 'timeout must be a float'
              end
            end

            if timeout.is_a?(Integer)
              timeout = timeout.to_f
            end

            unless timeout.is_a?(Float)
              raise Soren::Error::ArgumentError, 'timeout must be a float'
            end

            if timeout.negative?
              raise Soren::Error::ArgumentError, 'timeout must be greater than or equal to 0'
            end

            timeout
          end
        end
      end
    end
  end
end
