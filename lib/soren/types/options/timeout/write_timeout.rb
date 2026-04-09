# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative '../../../defaults/options'

module Soren
  module Types
    module Options
      module Timeout
        class WriteTimeout < Base
          #: (untyped) -> void
          def initialize(timeout)
            super(timeout, default: Soren::Defaults::Options::WRITE_TIMEOUT)
          end
        end
      end
    end
  end
end
