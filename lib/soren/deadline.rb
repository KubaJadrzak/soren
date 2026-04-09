# typed: strict
# frozen_string_literal: true

module Soren
  class Deadline
    #: (Integer?) -> Soren::Deadline?
    def self.start(timeout)
      return unless timeout

      timeout_seconds = timeout.to_f / 1000.0
      new(Process.clock_gettime(Process::CLOCK_MONOTONIC).to_f + timeout_seconds)
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
