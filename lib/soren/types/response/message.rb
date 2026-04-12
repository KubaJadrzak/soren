# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Response
      class Message
        #: (untyped) -> void
        def initialize(message)
          @message = validate(message) #: String
        end

        #: -> String
        def to_s
          @message
        end

        private

        #: (untyped) -> String
        def validate(message)
          unless message.is_a?(String) && !message.blank?
            raise Soren::Error::ParseError, 'message must be a non-empty String'
          end

          message
        end
      end
    end
  end
end
