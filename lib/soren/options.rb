# typed: strict
# frozen_string_literal: true

require_relative 'types/options/timeout'
require_relative 'defaults/options'

module Soren
  class Options
    attr_reader :read_timeout #: Soren::Types::Options::Timeout::ReadTimeout?
    attr_reader :connect_timeout #: Soren::Types::Options::Timeout::ConnectTimeout?
    attr_reader :write_timeout #: Soren::Types::Options::Timeout::WriteTimeout?

    #: (?read_timeout: untyped, ?connect_timeout: untyped, ?write_timeout: untyped) -> void
    def initialize(read_timeout: nil, connect_timeout: nil, write_timeout: nil)
      @read_timeout = Soren::Types::Options::Timeout::ReadTimeout.new(read_timeout) #: Soren::Types::Options::Timeout::ReadTimeout
      @connect_timeout = Soren::Types::Options::Timeout::ConnectTimeout.new(connect_timeout) #: Soren::Types::Options::Timeout::ConnectTimeout
      @write_timeout = Soren::Types::Options::Timeout::WriteTimeout.new(write_timeout) #: Soren::Types::Options::Timeout::WriteTimeout
    end
  end
end
