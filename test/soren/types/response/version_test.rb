# frozen_string_literal: true

require_relative '../../../test_helper'
require_relative '../../../../lib/soren/types/response/version'

module Soren
  module Types
    module Response
      class VersionTest < Minitest::Test
        def test_accepts_valid_http_version
          version = Version.new('HTTP/1.1')

          assert_equal 'HTTP/1.1', version.to_s
        end

        def test_rejects_invalid_http_version
          error = assert_raises(Soren::Error::ParseError) { Version.new('1.1') }

          assert_equal 'version must match HTTP/<major>.<minor>', error.message
        end
      end
    end
  end
end
