# typed: strict
# frozen_string_literal: true

require_relative 'soren/version'
require_relative 'soren/error'
require_relative 'soren/connection'

module Soren
  class << self
    #: (?host: untyped, ?port: untyped, ?scheme: untyped, ?uri: untyped) -> Soren::Connection
    def new(host: nil, port: nil, scheme: nil, uri: nil)
      Connection.new(host: host, port: port, scheme: scheme, uri: uri)
    end
  end
end
