# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/response/message'

module Soren
  module Types
    module Response
      class MessageTest < Minitest::Test
        def test_accepts_valid_message
          message = Message.new('Created')

          assert_equal 'Created', message.to_s
        end

        def test_accepts_empty_message
          message = Message.new('')

          assert_equal '', message.to_s
        end

        def test_rejects_non_string_message
          error = assert_raises(Soren::Error::ParseError) { Message.new(nil) }

          assert_equal 'message must be a String', error.message
        end
      end
    end
  end
end
