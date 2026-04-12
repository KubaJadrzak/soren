# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/response/code'

module Soren
  module Types
    module Response
      class CodeTest < Minitest::Test
        def test_accepts_valid_code
          code = Code.new(200)

          assert_equal 200, code.to_i
        end

        def test_no_body_is_true_for_two_zero_four
          assert_equal true, Code.new(204).no_body?
        end

        def test_no_body_is_true_for_three_zero_four
          assert_equal true, Code.new(304).no_body?
        end

        def test_no_body_is_false_for_two_zero_zero
          assert_equal false, Code.new(200).no_body?
        end

        def test_rejects_out_of_range_code
          error = assert_raises(Soren::Error::ParseError) { Code.new(99) }

          assert_equal 'code must be an Integer between 100 and 599', error.message
        end
      end
    end
  end
end
