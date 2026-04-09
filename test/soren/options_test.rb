require_relative '../test_helper'
require_relative '../../lib/soren/options'

module Soren
  class OptionsTest < Minitest::Test
    def test_defaults_to_reasonable_timeouts
      options = Options.new

      assert_instance_of Soren::Types::Options::Timeout::ReadTimeout, options.read_timeout
      assert_instance_of Soren::Types::Options::Timeout::ConnectTimeout, options.connect_timeout
      assert_instance_of Soren::Types::Options::Timeout::WriteTimeout, options.write_timeout

      assert_equal Soren::Defaults::Options::READ_TIMEOUT, options.read_timeout.to_i
      assert_equal Soren::Defaults::Options::CONNECT_TIMEOUT, options.connect_timeout.to_i
      assert_equal Soren::Defaults::Options::WRITE_TIMEOUT, options.write_timeout.to_i
    end

    def test_initializes_all_timeouts_with_shared_type
      options = Options.new(read_timeout: '1000', connect_timeout: 2000, write_timeout: 3000)

      assert_instance_of Soren::Types::Options::Timeout::ReadTimeout, options.read_timeout
      assert_instance_of Soren::Types::Options::Timeout::ConnectTimeout, options.connect_timeout
      assert_instance_of Soren::Types::Options::Timeout::WriteTimeout, options.write_timeout

      assert_equal 1000, options.read_timeout.to_i
      assert_equal 2000, options.connect_timeout.to_i
      assert_equal 3000, options.write_timeout.to_i
    end

    def test_rejects_invalid_timeout
      error = assert_raises(Soren::Error::ArgumentError) do
        Options.new(read_timeout: 'not-int')
      end

      assert_equal 'timeout must be an integer', error.message
    end

    def test_rejects_timeout_below_minimum
      error = assert_raises(Soren::Error::ArgumentError) do
        Options.new(read_timeout: 3)
      end

      assert_equal 'timeout must be at least 100 milliseconds', error.message
    end
  end
end
