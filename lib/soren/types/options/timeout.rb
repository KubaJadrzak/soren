# typed: strict
# frozen_string_literal: true

require_relative 'timeout/base'
require_relative 'timeout/read_timeout'
require_relative 'timeout/connect_timeout'
require_relative 'timeout/write_timeout'

module Soren
  module Types
    module Options
      module Timeout
      end
    end
  end
end
