# typed: strict
# frozen_string_literal: true

require 'zlib'

module Soren
  module Decoders
    class Deflate
      #: (String) -> void
      def initialize(body)
        @body = body #: String
      end

      #: -> String
      def decode
        Zlib::Inflate.inflate(@body)
      rescue Zlib::Error
        decode_raw_deflate
      end

      private

      #: -> String
      def decode_raw_deflate
        inflater = Zlib::Inflate.new(-Zlib::MAX_WBITS)
        inflater.inflate(@body)
      rescue Zlib::Error
        raise Soren::Error::ParseError, 'invalid deflate encoded body'
      ensure
        inflater&.close
      end
    end
  end
end
