# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    module Response
      class Version
        #: (untyped) -> void
        def initialize(version)
          @version = validate(version) #: String
        end

        #: -> String
        def to_s
          @version
        end

        private

        #: (untyped) -> String
        def validate(version)
          unless version.is_a?(String) && version.match?(%r{\AHTTP/\d+\.\d+\z})
            raise Soren::Error::ParseError, 'version must match HTTP/<major>.<minor>'
          end

          version
        end
      end
    end
  end
end
