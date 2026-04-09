# typed: strict
# frozen_string_literal: true

require_relative 'types/options/timeout'
require_relative 'defaults/options'

module Soren
  class Options
    AVAILABLE_OPTIONS = %i[read_timeout connect_timeout write_timeout].freeze

    attr_reader :read_timeout #: Soren::Types::Options::Timeout::ReadTimeout?
    attr_reader :connect_timeout #: Soren::Types::Options::Timeout::ConnectTimeout?
    attr_reader :write_timeout #: Soren::Types::Options::Timeout::WriteTimeout?

    # rubocop:disable Style/OptionHash
    #: (?untyped) -> void
    def initialize(options = {})
      normalized_options = normalize_options(options)

      @read_timeout = Soren::Types::Options::Timeout::ReadTimeout.new(normalized_options[:read_timeout]) #: Soren::Types::Options::Timeout::ReadTimeout
      @connect_timeout = Soren::Types::Options::Timeout::ConnectTimeout.new(normalized_options[:connect_timeout]) #: Soren::Types::Options::Timeout::ConnectTimeout
      @write_timeout = Soren::Types::Options::Timeout::WriteTimeout.new(normalized_options[:write_timeout]) #: Soren::Types::Options::Timeout::WriteTimeout
    end
    # rubocop:enable Style/OptionHash

    private

    #: (untyped) -> Hash[Symbol, untyped]
    def normalize_options(options)
      unless options.is_a?(Hash)
        raise Soren::Error::ArgumentError, 'options must be a Hash'
      end

      normalized_options = {} #: Hash[Symbol, untyped]

      options.each do |key, value|
        option_key = normalize_key(key)

        unless AVAILABLE_OPTIONS.include?(option_key)
          raise Soren::Error::ArgumentError, "unsupported option: #{key}"
        end

        normalized_options[option_key] = value
      end

      normalized_options
    end

    #: (Symbol | String) -> Symbol
    def normalize_key(key)
      return key if key.is_a?(Symbol)
      return key.to_sym if key.is_a?(String)

      raise Soren::Error::ArgumentError, 'option keys must be strings or symbols'
    end
  end
end
