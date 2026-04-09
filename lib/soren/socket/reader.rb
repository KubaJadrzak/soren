# typed: strict
# frozen_string_literal: true

require 'stringio'

module Soren
  module Socket
    class Reader
      #: (untyped) -> void
      def initialize(source)
        @io = to_io(source) #: untyped
      end

      #: -> String?
      def read_line
        @io.gets
      end

      #: (String) -> String?
      def read_line_with_terminator(terminator)
        @io.gets(terminator)
      end

      #: (Integer) -> String
      def read_exactly(length)
        return '' if length <= 0

        buffer = +''
        while buffer.bytesize < length
          chunk = @io.read(length - buffer.bytesize)
          raise Soren::Error::ReadError, 'unexpected EOF while reading' if chunk.nil?

          buffer << chunk
        end

        buffer
      end

      #: -> String
      def read_all
        @io.read.to_s
      end

      private

      #: (untyped) -> untyped
      def to_io(source)
        return source if source.respond_to?(:gets) && source.respond_to?(:read)

        if source.is_a?(String)
          return StringIO.new(source)
        end

        raise Soren::Error::ParseError, 'source must be a readable IO object or String'
      end
    end
  end
end
