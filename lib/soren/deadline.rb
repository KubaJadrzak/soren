# typed: strict
# frozen_string_literal: true

module Soren
  class Deadline
    class << self
      #: (Float?) -> Soren::Deadline?
      def start(timeout)
        return unless timeout

        new(Process.clock_gettime(Process::CLOCK_MONOTONIC).to_f + timeout)
      end
    end

    #: (Float) -> void
    def initialize(deadline_at)
      @deadline_at = deadline_at #: Float
    end

    #: -> Float
    def remaining
      time = @deadline_at - Process.clock_gettime(Process::CLOCK_MONOTONIC)
      time > 0 ? time : 0.0
    end

    #: -> bool
    def expired?
      remaining <= 0
    end
  end
end
