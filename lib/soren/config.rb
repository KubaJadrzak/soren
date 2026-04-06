# typed: strict
# frozen_string_literal: true

require_relative 'types/config/timeout'
require_relative 'defaults/config'

module Soren
  class Config
    attr_reader :read_timeout #: Soren::Types::Config::Timeout::ReadTimeout?
    attr_reader :connect_timeout #: Soren::Types::Config::Timeout::ConnectTimeout?
    attr_reader :write_timeout #: Soren::Types::Config::Timeout::WriteTimeout?

    #: (?read_timeout: untyped, ?connect_timeout: untyped, ?write_timeout: untyped) -> void
    def initialize(read_timeout: nil, connect_timeout: nil, write_timeout: nil)
      @read_timeout = Soren::Types::Config::Timeout::ReadTimeout.new(read_timeout) #: Soren::Types::Config::Timeout::ReadTimeout
      @connect_timeout = Soren::Types::Config::Timeout::ConnectTimeout.new(connect_timeout) #: Soren::Types::Config::Timeout::ConnectTimeout
      @write_timeout = Soren::Types::Config::Timeout::WriteTimeout.new(write_timeout) #: Soren::Types::Config::Timeout::WriteTimeout
    end
  end
end
