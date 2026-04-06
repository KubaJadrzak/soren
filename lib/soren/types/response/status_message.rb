# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Response
      class StatusMessage
        #: (untyped) -> void
        def initialize(status_message)
          @status_message = validate(status_message) #: String
        end

        #: -> String
        def to_s
          @status_message
        end

        private

        #: (untyped) -> String
        def validate(status_message)
          unless status_message.is_a?(String) && !status_message.blank?
            raise Soren::Error::ArgumentError, 'status_message must be a non-empty String'
          end

          status_message
        end
      end
    end
  end
end
