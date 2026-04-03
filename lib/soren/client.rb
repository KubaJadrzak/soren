# typed: strict
# frozen_string_literal: true

module Soren
  class Client
    #: (host: untyped, port: untyped, scheme: untyped) -> void
    def initialize(host:, port:, scheme:)
      @host = Soren::Types::Host.new(host: host) #: Soren::Types::Host
      @port = Soren::Types::Port.new(port: port) #: Soren::Types::Port
      @scheme = Soren::Types::Scheme.new(scheme: scheme) #: Soren::Types::Scheme
    end
  end
end
