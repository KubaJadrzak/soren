# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Response
      class StatusCode
        #: (untyped) -> void
        def initialize(status_code)
          @status_code = validate(status_code) #: Integer
        end

        #: -> Integer
        def to_i
          @status_code
        end

        private

        #: (untyped) -> Integer
        def validate(status_code)
          unless status_code.is_a?(Integer) && status_code.between?(100, 599)
            raise Soren::Error::ArgumentError, 'status_code must be an Integer between 100 and 599'
          end

          status_code
        end
      end
    end
  end
end
