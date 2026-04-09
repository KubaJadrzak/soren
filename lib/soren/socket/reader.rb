# typed: strict
# frozen_string_literal: true

require 'stringio'

require_relative '../deadline'

module Soren
  module Socket
    class Reader
      #: (untyped, ?deadline: Deadline?) -> void
      def initialize(source, deadline: nil)
        @io = to_io(source) #: untyped
        @deadline = deadline #: Deadline?
      end

      #: -> String?
      def read_line
        check_deadline_expired
        @io.gets
      end

      #: (String) -> String?
      def read_line_with_terminator(terminator)
        check_deadline_expired
        @io.gets(terminator)
      end

      #: (Integer) -> String
      def read_exactly(length)
        return '' if length <= 0

        check_deadline_expired
        buffer = +''
        while buffer.bytesize < length
          check_deadline_expired
          chunk = @io.read(length - buffer.bytesize)
          raise Soren::Error::ReadError, 'unexpected EOF while reading' if chunk.nil?

          buffer << chunk
        end

        buffer
      end

      #: -> String
      def read_all
        check_deadline_expired
        @io.read.to_s
      end

      private

      #: -> void
      def check_deadline_expired
        return if @deadline.nil?

        raise Soren::Error::ReadTimeout if @deadline.expired?
      end

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
