# typed: strict
# frozen_string_literal: true

require_relative 'types/request/target'
require_relative 'types/request/method'
require_relative 'types/request/headers'
require_relative 'types/request/body'

module Soren
  class Request

    attr_reader :method #: Soren::Types::Request::Method?
    attr_reader :target #: Soren::Types::Request::Target?
    attr_reader :headers #: Soren::Types::Request::Headers?
    attr_reader :body #: Soren::Types::Request::Body?

    #: (method: untyped, target: untyped, ?headers: untyped, ?body: untyped) -> void
    def initialize(method:, target:, headers: {}, body: nil)
      @method = Soren::Types::Request::Method.new(method) #: Soren::Types::Request::Method
      @target = Soren::Types::Request::Target.new(target) #: Soren::Types::Request::Target
      @body = Soren::Types::Request::Body.new(body) #: Soren::Types::Request::Body
      @headers = Soren::Types::Request::Headers.new(headers, content_length: @body.to_http&.bytesize) #: Soren::Types::Request::Headers
    end

    #: (host: String) -> String
    def to_http(host:)
      request_line = "#{@method.to_http} #{@target.to_http} HTTP/1.1"
      header_lines = @headers.to_http(host: host)
      body_text = @body.to_http

      if body_text.nil?
        [request_line, *header_lines, '', ''].join("\r\n")
      else
        [request_line, *header_lines, '', body_text].join("\r\n")
      end
    end

  end
end
