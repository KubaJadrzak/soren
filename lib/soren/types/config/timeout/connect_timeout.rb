# typed: strict
# frozen_string_literal: true

require_relative 'base'
require_relative '../../../defaults/config'

module Soren
  module Types
    module Config
      module Timeout
        class ConnectTimeout < Base
          #: (untyped) -> void
          def initialize(timeout)
            super(timeout, default: Soren::Defaults::Config::CONNECT_TIMEOUT)
          end
        end
      end
    end
  end
end
