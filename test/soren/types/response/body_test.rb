require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/response/body'

module Soren
  module Types
    module Response
      class BodyTest < Minitest::Test
        def test_accepts_string_body
          body = Body.new('hello')

          assert_equal 'hello', body.to_s
        end

        def test_rejects_non_string_body
          error = assert_raises(Soren::Error::ResponseError) { Body.new(nil) }

          assert_equal 'body must be a String', error.message
        end
      end
    end
  end
end
