# typed: strict
# frozen_string_literal: true

require_relative 'types/response/status_code'
require_relative 'types/response/status_message'
require_relative 'types/response/version'
require_relative 'types/response/headers'
require_relative 'types/response/body'
require_relative 'parsers/response'
require_relative 'deadline'

module Soren
  class Response
    attr_reader :status_code #: Soren::Types::Response::StatusCode?
    attr_reader :status_message #: Soren::Types::Response::StatusMessage?
    attr_reader :version #: Soren::Types::Response::Version?
    attr_reader :headers #: Soren::Types::Response::Headers?
    attr_reader :body #: Soren::Types::Response::Body?

    #: (untyped, ?deadline: Deadline?) -> void
    def initialize(socket, deadline: nil)
      parsed_response = Soren::Parsers::Response.new(socket, deadline: deadline).parse

      parsed_status_line = parsed_response[:status_line]
      @version = Soren::Types::Response::Version.new(parsed_status_line[:version]) #: Soren::Types::Response::Version?
      @status_code = Soren::Types::Response::StatusCode.new(parsed_status_line[:status_code]) #: Soren::Types::Response::StatusCode?
      @status_message = Soren::Types::Response::StatusMessage.new(parsed_status_line[:status_message]) #: Soren::Types::Response::StatusMessage?

      @headers = parsed_response[:headers] #: Soren::Types::Response::Headers?
      @body = Soren::Types::Response::Body.new(parsed_response[:body]) #: Soren::Types::Response::Body?
    end
  end
end
