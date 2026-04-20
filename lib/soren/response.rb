# typed: strict
# frozen_string_literal: true

require_relative 'types/response/code'
require_relative 'types/response/message'
require_relative 'types/response/version'
require_relative 'types/response/headers'
require_relative 'types/response/body'

module Soren
  class Response

    #: (Hash[Symbol, untyped]) -> void
    def initialize(parsed_response)
      parsed_status_line = parsed_response[:status_line]
      @version = parsed_status_line[:version] #: Soren::Types::Response::Version
      @code = parsed_status_line[:code] #: Soren::Types::Response::Code
      @message = parsed_status_line[:message] #: Soren::Types::Response::Message

      @headers = parsed_response[:headers] #: Soren::Types::Response::Headers
      @body = parsed_response[:body] #: Soren::Types::Response::Body
    end

    #: -> Integer
    def code
      @code.to_i
    end

    #: -> String
    def message
      @message.to_s
    end

    #: -> String
    def version
      @version.to_s
    end

    #: -> Hash[String, Array[String]]
    def headers
      @headers.to_h
    end

    #: -> String
    def body
      @body.to_s
    end

    class << self
      #: (code: Integer, message: String, version: String, headers: Hash[String, Array[String]], body: String) -> Soren::Response
      def from_parts(code:, message:, version:, headers:, body:)
        new({
              status_line: {
                version: Types::Response::Version.new("HTTP/#{version}"),
                code:    Types::Response::Code.new(code),
                message: Types::Response::Message.new(message),
              },
              headers:     Types::Response::Headers.new(headers),
              body:        Types::Response::Body.new(body),
            })
      end
    end
  end
end
