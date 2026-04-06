require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/response/status_message'

module Soren
  module Types
    module Response
      class StatusMessageTest < Minitest::Test
        def test_accepts_valid_status_message
          status_message = StatusMessage.new('Created')

          assert_equal 'Created', status_message.to_s
        end

        def test_rejects_empty_status_message
          error = assert_raises(Soren::Error::ArgumentError) { StatusMessage.new('  ') }

          assert_equal 'status_message must be a non-empty String', error.message
        end
      end
    end
  end
end
