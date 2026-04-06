# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative '../../../defaults/config'

module Soren
  module Types
    module Config
      module Timeout
        class ReadTimeout < Base
          #: (untyped) -> void
          def initialize(timeout)
            super(timeout, default: Soren::Defaults::Config::READ_TIMEOUT)
          end
        end
      end
    end
  end
end
