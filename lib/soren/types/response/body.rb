# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Response
      class Body
        #: (untyped) -> void
        def initialize(body)
          @body = validate(body) #: String
        end

        #: -> String
        def to_s
          @body
        end

        private

        #: (untyped) -> String
        def validate(body)
          unless body.is_a?(String)
            raise Soren::Error::ParseError, 'body must be a String'
          end

          body
        end
      end
    end
  end
end
