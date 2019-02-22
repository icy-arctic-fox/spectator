module Spectator
  # Outcome of all tests in a suite.
  class Report
    # Total length of time it took to execute the test suite.
    # This includes examples, hooks, and framework processes.
    getter runtime : Time::Span

    # Number of passing examples.
    getter successful_count = 0

    # Number of failing examples (includes errors).
    getter failed_count = 0

    # Number of examples that had errors.
    getter error_count = 0

    # Number of pending examples.
    getter pending_count = 0

    # Creates the report.
    # The *results* are from running the examples in the test suite.
    # The *runtime* is the total time it took to execute the suite.
    def initialize(@results : Array(Result), @runtime)
      @results.each do |result|
        case result
        when SuccessfulResult
          @successful_count += 1
        when ErroredResult
          @error_count += 1
          @failed_count += 1
        when FailedResult
          @failed_count += 1
        when PendingResult
          @pending_count += 1
        end
      end
    end

    # Number of examples.
    def example_count
      @results.size
    end

    # Indicates whether the test suite failed.
    def failed?
      failed_count > 0
    end

    # Returns a set of results for all failed examples.
    def failures
      @results.each.compact_map(&.as?(FailedResult))
    end

    # Returns a set of results for all errored examples.
    def errors
      @results.each.compact_map(&.as?(ErroredResult))
    end

    # Length of time it took to run just example code.
    # This does not include hooks,
    # but it does include pre- and post-conditions.
    def example_runtime
      @results.each.compact_map(&.as?(FinishedResult)).sum(&.elapsed)
    end

    # Length of time spent in framework processes and hooks.
    def overhead_time
      @runtime - example_runtime
    end
  end
end
