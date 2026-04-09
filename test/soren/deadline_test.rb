require_relative '../test_helper'
require_relative '../../lib/soren/deadline'

module Soren
  class DeadlineTest < Minitest::Test
    def test_start_returns_nil_without_timeout
      assert_nil Deadline.start(nil)
    end

    def test_start_uses_monotonic_clock_and_millisecond_timeout
      deadline = Process.stub(:clock_gettime, ->(*_) { 100.0 }) do
        Deadline.start(2500)
      end

      assert_in_delta 1.5, Process.stub(:clock_gettime, ->(*_) { 101.0 }) { deadline.remaining }, 0.0001
    end

    def test_remaining_returns_zero_when_deadline_passed
      deadline = Deadline.new(99.0)

      remaining = Process.stub(:clock_gettime, ->(*_) { 100.0 }) { deadline.remaining }

      assert_equal 0.0, remaining
    end

    def test_expired_is_false_when_deadline_not_reached
      deadline = Deadline.new(100.1)

      expired = Process.stub(:clock_gettime, ->(*_) { 100.0 }) { deadline.expired? }

      assert_equal false, expired
    end

    def test_expired_is_true_when_deadline_reached
      deadline = Deadline.new(100.0)

      expired = Process.stub(:clock_gettime, ->(*_) { 100.0 }) { deadline.expired? }

      assert_equal true, expired
    end
  end
end
