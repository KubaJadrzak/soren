require_relative '../test_helper'
require_relative '../../lib/soren/config'

module Soren
  class ConfigTest < Minitest::Test
    def test_defaults_to_reasonable_timeouts
      config = Config.new

      assert_instance_of Soren::Types::Config::Timeout::ReadTimeout, config.read_timeout
      assert_instance_of Soren::Types::Config::Timeout::ConnectTimeout, config.connect_timeout
      assert_instance_of Soren::Types::Config::Timeout::WriteTimeout, config.write_timeout

      assert_equal Soren::Defaults::Config::READ_TIMEOUT, config.read_timeout.to_i
      assert_equal Soren::Defaults::Config::CONNECT_TIMEOUT, config.connect_timeout.to_i
      assert_equal Soren::Defaults::Config::WRITE_TIMEOUT, config.write_timeout.to_i
    end

    def test_initializes_all_timeouts_with_shared_type
      config = Config.new(read_timeout: '1', connect_timeout: 2, write_timeout: 3)

      assert_instance_of Soren::Types::Config::Timeout::ReadTimeout, config.read_timeout
      assert_instance_of Soren::Types::Config::Timeout::ConnectTimeout, config.connect_timeout
      assert_instance_of Soren::Types::Config::Timeout::WriteTimeout, config.write_timeout

      assert_equal 1, config.read_timeout.to_i
      assert_equal 2, config.connect_timeout.to_i
      assert_equal 3, config.write_timeout.to_i
    end

    def test_rejects_invalid_timeout
      error = assert_raises(Soren::Error::ArgumentError) do
        Config.new(read_timeout: 'not-int')
      end

      assert_equal 'timeout must be an integer', error.message
    end
  end
end
