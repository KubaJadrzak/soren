# typed: strict
# frozen_string_literal: true

require_relative 'types/target'
require_relative 'types/method'
require_relative 'types/headers'
require_relative 'types/body'

module Soren
  class Request

    attr_reader :method #: Soren::Types::Method?
    attr_reader :target #: Soren::Types::Target?
    attr_reader :headers #: Soren::Types::Headers?
    attr_reader :body #: Soren::Types::Body?

    #: (method: untyped, target: untyped, ?headers: untyped, ?body: untyped) -> void
    def initialize(method:, target:, headers: {}, body: nil)
      @method = Soren::Types::Method.new(method) #: Soren::Types::Method
      @target = Soren::Types::Target.new(target) #: Soren::Types::Target
      @headers = Soren::Types::Headers.new(headers) #: Soren::Types::Headers
      @body = Soren::Types::Body.new(body) #: Soren::Types::Body
    end

    #: (host: untyped) -> String
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
