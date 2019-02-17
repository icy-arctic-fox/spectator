module Spectator
  # Outcome of all tests in a suite.
  class Report
    # Total length of time it took to execute the test suite.
    # This includes examples, hooks, and framework processes.
    getter runtime : Time::Span

    # Creates the report.
    # The `results` are from running the examples in the test suite.
    # The `runtime` is the total time it took to execute the suite.
    def initialize(@results : Array(Result), @runtime)
    end

    # Number of examples.
    def example_count
      @results.size
    end

    # Number of passing examples.
    def successful_count
      @results.count(&.is_a?(SuccessfulResult))
    end

    # Number of failing examples (includes errors).
    def failed_count
      @results.count(&.is_a?(FailedResult))
    end

    # Number of examples that had errors.
    def error_count
      @results.count(&.is_a?(ErroredResult))
    end

    # Number of pending examples.
    def pending_count
      @results.count(&.is_a?(PendingResult))
    end

    # Returns a set of results for all failed examples.
    def failures
      @results.select(&.is_a?(FailedResult)).map(&.as(FailedResult))
    end

    # Returns a set of results for all errored examples.
    def errors
      @results.select(&.is_a?(ErroredResult)).map(&.as(ErroredResult))
    end

    # Length of time it took to run just example code.
    # This does not include hooks,
    # but it does include pre- and post-conditions.
    def example_runtime
      @results.sum do |result|
        if result.is_a?(FinishedResult)
          result.elapsed
        else
          Time::Span.zero
        end
      end
    end

    # Length of time spent in framework processes and hooks.
    def overhead_time
      @runtime - example_runtime
    end
  end
end
