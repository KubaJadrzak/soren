# typed: strict
# frozen_string_literal: true

require_relative '../../../defaults/options'

module Soren
  module Types
    module Options
      module Timeout
        class Base
          #: (untyped, ?default: Integer?) -> void
          def initialize(timeout, default: nil)
            timeout = default if timeout.blank?
            @timeout = validate(timeout) #: Integer
          end

          #: -> Integer
          def to_i
            @timeout
          end

          private

          #: (untyped) -> Integer
          def validate(timeout)
            if timeout.is_a?(String)
              begin
                timeout = Integer(timeout)
              rescue ArgumentError
                raise Soren::Error::ArgumentError, 'timeout must be an integer'
              end
            end

            unless timeout.is_a?(Integer)
              raise Soren::Error::ArgumentError, 'timeout must be an integer'
            end

            if timeout.negative?
              raise Soren::Error::ArgumentError, 'timeout must be greater than or equal to 0'
            end

            if timeout < Soren::Defaults::Options::MIN_TIMEOUT
              raise Soren::Error::ArgumentError,
                    "timeout must be at least #{Soren::Defaults::Options::MIN_TIMEOUT} milliseconds"
            end

            timeout
          end
        end
      end
    end
  end
end
