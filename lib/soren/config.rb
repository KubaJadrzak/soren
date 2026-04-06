# typed: strict
# frozen_string_literal: true

module Soren
  class Config
    attr_reader :read_timeout #: Float?
    attr_reader :connect_timeout #: Float?
    attr_reader :write_timeout #: Float?

    #: (?read_timeout: untyped, ?connect_timeout: untyped, ?write_timeout: untyped) -> void
    def initialize(read_timeout: nil, connect_timeout: nil, write_timeout: nil)
      @read_timeout = normalize_timeout(read_timeout, key: 'read_timeout') #: Float?
      @connect_timeout = normalize_timeout(connect_timeout, key: 'connect_timeout') #: Float?
      @write_timeout = normalize_timeout(write_timeout, key: 'write_timeout') #: Float?
    end

    private

    #: (untyped, key: String) -> Float?
    def normalize_timeout(value, key:)
      return if value.nil?

      timeout = Float(value)
      if timeout.negative?
        raise Soren::Error::ArgumentError, "#{key} must be greater than or equal to 0"
      end

      timeout
    rescue ArgumentError, TypeError
      raise Soren::Error::ArgumentError, "#{key} must be numeric"
    end
  end
end
