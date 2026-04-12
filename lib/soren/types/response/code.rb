# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Response
      class Code
        NO_CONTENT = 204
        NOT_MODIFIED = 304

        #: (untyped) -> void
        def initialize(code)
          @code = validate(code) #: Integer
        end

        #: -> Integer
        def to_i
          @code
        end

        #: -> bool
        def no_body?
          [NO_CONTENT, NOT_MODIFIED].include?(@code)
        end

        private

        #: (untyped) -> Integer
        def validate(code)
          unless code.is_a?(Integer) && code.between?(100, 599)
            raise Soren::Error::ParseError, 'code must be an Integer between 100 and 599'
          end

          code
        end
      end
    end
  end
end
