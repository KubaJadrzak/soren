# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/soren/options'

module Soren
  class OptionsTest < Minitest::Test
    def test_defaults_to_reasonable_timeouts
      options = Options.new

      assert_equal Soren::Defaults::Options::READ_TIMEOUT, options.read_timeout.to_f
      assert_equal Soren::Defaults::Options::CONNECT_TIMEOUT, options.connect_timeout.to_f
      assert_equal Soren::Defaults::Options::WRITE_TIMEOUT, options.write_timeout.to_f
    end

    def test_initializes_timeouts_from_symbol_keys
      options = Options.new({ read_timeout: '1.5', connect_timeout: 2.0, write_timeout: 3 })

      assert_equal 1.5, options.read_timeout.to_f
      assert_equal 2.0, options.connect_timeout.to_f
      assert_equal 3.0, options.write_timeout.to_f
    end

    def test_initializes_timeouts_from_string_keys
      options = Options.new({ 'read_timeout' => '1.25', 'connect_timeout' => 2, 'write_timeout' => '3.5' })

      assert_equal 1.25, options.read_timeout.to_f
      assert_equal 2.0, options.connect_timeout.to_f
      assert_equal 3.5, options.write_timeout.to_f
    end

    def test_rejects_invalid_timeout
      error = assert_raises(Soren::Error::ArgumentError) do
        Options.new({ read_timeout: 'not-float' })
      end

      assert_equal 'timeout must be a float', error.message
    end

    def test_rejects_unsupported_option
      error = assert_raises(Soren::Error::ArgumentError) do
        Options.new({ unknown_timeout: 1.0 })
      end

      assert_equal 'unsupported option: unknown_timeout', error.message
    end
  end
end
