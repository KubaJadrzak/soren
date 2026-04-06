require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/response/status_code'

module Soren
  module Types
    module Response
      class StatusCodeTest < Minitest::Test
        def test_accepts_valid_status_code
          status_code = StatusCode.new(200)

          assert_equal 200, status_code.to_i
        end

        def test_rejects_out_of_range_status_code
          error = assert_raises(Soren::Error::ParseError) { StatusCode.new(99) }

          assert_equal 'status_code must be an Integer between 100 and 599', error.message
        end
      end
    end
  end
end
