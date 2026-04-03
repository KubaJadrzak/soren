# typed: strict
# frozen_string_literal: true

module Soren
  module Types
    class Port
      #: (untyped) -> void
      def initialize(port)
        @port = validate(port) #: Integer
      end

      #: -> String
      def to_s
        @port.to_s
      end

      #: -> Integer
      def to_i
        @port
      end

      private

      #: (untyped) -> Integer
      def validate(port)
        if port.is_a?(String)
          begin
            port = Integer(port)
          rescue ArgumentError
            raise Soren::Error::ArgumentError, 'port must be a valid integer or string convertible to integer'
          end
        end

        unless port.is_a?(Integer)
          raise Soren::Error::ArgumentError, 'port must be an integer'
        end

        unless port.between?(1, 65535)
          raise Soren::Error::ArgumentError, 'port must be between 1 and 65535'
        end

        port
      end
    end
  end
end
