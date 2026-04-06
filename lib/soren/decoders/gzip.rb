# typed: strict
# frozen_string_literal: true

require 'zlib'
require 'stringio'

module Soren
  module Decoders
    class Gzip
      #: (String) -> void
      def initialize(body)
        @body = body #: String
      end

      #: -> String
      def decode
        Zlib::GzipReader.new(StringIO.new(@body)).read
      rescue Zlib::Error
        raise Soren::Error::ParseError, 'invalid gzip encoded body'
      end
    end
  end
end
