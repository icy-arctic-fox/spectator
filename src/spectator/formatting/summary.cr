require "../fail_result"
require "./components"

module Spectator::Formatting
  # Mix-in providing common output for summarized results.
  # Implements the following methods:
  # `Formatter#start_dump`, `Formatter#dump_pending`, `Formatter#dump_failures`,
  # `Formatter#dump_summary`, and `Formatter#dump_profile`.
  # Classes including this module must implement `#io`.
  module Summary
    # Stream to write results to.
    private abstract def io

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
      examples.each_with_index(1) do |example, index|
        result = example.result.as(PendingResult)
        io.puts Components::PendingResultBlock.new(example, index, result)
      end
    end

    # Invoked after testing completes with a list of failed examples.
    # This method will be called with an empty list if there were no failures.
    # Called after `#dump_pending` and before `#dump_summary`.
    def dump_failures(notification)
      return if (examples = notification.examples).empty?

      io.puts "Failures:"
      io.puts
      examples.each_with_index(1) do |example, index|
        dump_failed_example(example, index)
      end
    end

    # Invoked after testing completes with profiling information.
    # This method is only called if profiling is enabled.
    # Called after `#dump_failures` and before `#dump_summary`.
    def dump_profile(notification)
      io.puts Components::Profile.new(notification.profile)
    end

    # Invoked after testing completes with summarized information from the test suite.
    # Called after `#dump_failures` and before `#dump_profile`.
    def dump_summary(notification)
      report = notification.report
      io.puts Components::Stats.new(report)

      return if (failures = report.failures).empty?

      io.puts Components::FailureCommandList.new(failures)
    end

    # Displays one or more blocks for a failed example.
    # Each block is a failed expectation or error raised in the example.
    private def dump_failed_example(example, index)
      # Retrieve the ultimate reason for failing.
      error = example.result.as?(FailResult).try(&.error)

      # Prevent displaying duplicated output from expectation.
      # Display `ExampleFailed` but not `ExpectationFailed`.
      error = nil if error.responds_to?(:expectation)

      # Gather all failed expectations.
      failed_expectations = example.result.expectations.select(&.failed?)
      block_count = failed_expectations.size
      block_count += 1 if error # Add an extra block for final error if it's significant.

      # Don't use sub-index if there was only one problem.
      if block_count == 1
        if error
          io.puts Components::ErrorResultBlock.new(example, index, error)
        else
          io.puts Components::FailResultBlock.new(example, index, failed_expectations.first)
        end
      else
        failed_expectations.each_with_index(1) do |expectation, subindex|
          io.puts Components::FailResultBlock.new(example, index, expectation, subindex)
        end
        io.puts Components::ErrorResultBlock.new(example, index, error, block_count) if error
      end
    end
  end
end
