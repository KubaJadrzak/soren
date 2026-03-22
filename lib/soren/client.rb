# typed: strict
# frozen_string_literal: true

module Soren
  class Client
    #: (host: untyped, port: untyped) -> void
    def initialize(host:, port:)
      @host = Soren::Types::Host.new(host: host) #: Soren::Types::Host
      @port = port
    end
  end
end
