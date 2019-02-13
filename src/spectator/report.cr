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
      @results.count(&.successful?)
    end

    # Number of failing examples (includes errors).
    def failed_count
      @results.count(&.failed?)
    end

    # Returns a set of results for all failed examples.
    def failures
      @results.select(&.failed?).map(&.as(FailedResult))
    end

    # Number of examples that had errors.
    def error_count
      @results.count(&.errored?)
    end

    # Returns a set of results for all errored examples.
    def errors
      @results.select(&.errored?).map(&.as(ErroredResult))
    end

    # Number of pending examples.
    def pending_count
      @results.count(&.pending?)
    end

    # Length of time it took to run just example code.
    # This does not include hooks,
    # but it does include pre- and post-conditions.
    def example_runtime
      @results.map(&.elapsed).sum
    end

    # Length of time spent in framework processes and hooks.
    def overhead_time
      @runtime - example_runtime
    end
  end
end
