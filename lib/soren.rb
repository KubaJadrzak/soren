# typed: strict
# frozen_string_literal: true

require_relative 'soren/version'
require_relative 'soren/client'
require_relative 'soren/error'

module Soren
  class << self
    #: (host: untyped, port: untyped, scheme: untyped) -> Soren::Client
    def new(host:, port:, scheme:)
      Client.new(host: host, port: port, scheme:)
    end
  end
end
