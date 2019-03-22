module Spectator::Formatting
  # Mix-in for producing a human-readable summary of a test suite.
  module SuiteSummary
    # Does nothing when starting a test suite.
    def start_suite(suite)
      # ...
    end

    # Produces the summary of test suite from a report.
    # A block describing each failure is displayed.
    # At the end, the totals and runtime are printed.
    def end_suite(report)
      if report.example_count > 0
        @io.puts if is_a?(DotsFormatter)
        @io.puts
      end
      failures(report.failures) if report.failed_count > 0
      stats(report)
      remaining(report) if report.remaining?
      if report.failed?
        if report.examples_ran > 0
          failure_commands(report.failures)
        else
          @io.puts Color.failure("Failing because no tests were run (fail-blank)")
        end
      end
    end

    # Produces the failure section of the summary.
    # This has a "Failures" title followed by a block for each failure.
    private def failures(failures)
      @io.puts "Failures:"
      @io.puts
      failures.each_with_index do |result, index|
        @io.puts FailureBlock.new(index + 1, result)
      end
    end

    # Produces the statistical section of the summary.
    # This contains how long the suite took to run
    # and the counts for the results (total, failures, errors, and pending).
    private def stats(report)
      @io.puts Runtime.new(report.runtime)
      @io.puts StatsCounter.new(report).color
    end

    # Produces the skipped tests text if fail-fast is enabled and tests were omitted.
    private def remaining(report)
      text = RemainingText.new(report.remaining_count)
      @io.puts Color.failure(text)
    end

    # Produces the failure commands section of the summary.
    # This provides a set of commands the user can run
    # to test just the examples that failed.
    private def failure_commands(failures)
      @io.puts
      @io.puts "Failed examples:"
      @io.puts
      failures.each do |result|
        @io << FailureCommand.color(result)
        @io << ' '
        @io.puts Comment.color(result.example)
      end
    end
  end
end
