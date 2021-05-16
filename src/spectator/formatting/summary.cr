require "./components"

module Spectator::Formatting
  # Mix-in providing common output for summarized results.
  # Implements the following methods:
  # `Formatter#start_dump`, `Formatter#dump_pending`, `Formatter#dump_failures`,
  # `Formatter#dump_summary`, and `Formatter#dump_profile`.
  # Classes including this module must implement `#io`.
  module Summary
    # Stream to write results to.
    private abstract def io : IO

    def start_dump
      io.puts
    end

    # Invoked after testing completes with a list of pending examples.
    # This method will be called with an empty list if there were no pending (skipped) examples.
    # Called after `#start_dump` and before `#dump_failures`.
    def dump_pending(notification)
      return if (examples = notification.examples).empty?

      io.puts "Pending:"
      io.puts
      examples.each_with_index do |example, index|
        io.puts Components::PendingBlock.new(example, index + 1)
      end
    end

    # Invoked after testing completes with a list of failed examples.
    # This method will be called with an empty list if there were no failures.
    # Called after `#dump_pending` and before `#dump_summary`.
    def dump_failures(notification)
      return if (examples = notification.examples).empty?

      io.puts "Failures:"
      io.puts
      examples.each_with_index do |example, index|
        io.puts Components::FailureBlock.new(example, index + 1)
      end
    end

    # Invoked after testing completes with summarized information from the test suite.
    # Called after `#dump_failures` and before `#dump_profile`.
    def dump_summary(notification)
      report = notification.report
      io.puts Components::Stats.new(report)

      return if (failures = report.failures).empty?

      io.puts Components::FailureCommandList.new(failures)
    end

    # Invoked after testing completes with profiling information.
    # This method is only called if profiling is enabled.
    # Called after `#dump_summary` and before `#close`.
    def dump_profile(_notification)
    end
  end
end
