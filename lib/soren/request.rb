# typed: strict
# frozen_string_literal: true

require_relative 'types/target'
require_relative 'types/headers'
require_relative 'types/body'

module Soren
  class Request
    #: (target: untyped, ?headers: untyped, ?body: untyped) -> void
    def initialize(target:, headers: {}, body: nil)
      @target = Soren::Types::Target.new(target) #: Soren::Types::Target
      @headers = Soren::Types::Headers.new(headers) #: Soren::Types::Headers
      @body = Soren::Types::Body.new(body) #: Soren::Types::Body
    end

    attr_reader :target #: Soren::Types::Target?
    attr_reader :headers #: Soren::Types::Headers?
    attr_reader :body #: Soren::Types::Body?
  end
end
