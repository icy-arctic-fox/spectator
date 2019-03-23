require "./result"

module Spectator
  # Outcome of all tests in a suite.
  class Report
    include Enumerable(Result)

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

    # Number of remaining tests.
    # This will be greater than zero only in fail-fast mode.
    getter remaining_count

    # Creates the report.
    # The *results* are from running the examples in the test suite.
    # The *runtime* is the total time it took to execute the suite.
    # The *remaining_count* is the number of tests skipped due to fail-fast.
    # The *fail_blank* flag indicates whether it is a failure if there were no tests run.
    def initialize(@results : Array(Result), @runtime, @remaining_count = 0, @fail_blank = false)
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

    # Creates the report.
    # This constructor is intended for reports of subsets of results.
    # The *results* are from running the examples in the test suite.
    # The runtime is calculated from the *results*.
    def initialize(results : Array(Result))
      runtime = results.each.compact_map(&.as?(FinishedResult)).sum(&.elapsed)
      initialize(results, runtime)
    end

    # Yields each result in turn.
    def each
      @results.each do |result|
        yield result
      end
    end

    # Number of examples.
    def example_count
      @results.size
    end

    # Number of examples run (not skipped or pending).
    def examples_ran
      @successful_count + @failed_count
    end

    # Indicates whether the test suite failed.
    def failed?
      failed_count > 0 || (@fail_blank && examples_ran == 0)
    end

    # Indicates whether there were skipped tests
    # because of a failure causing the test to abort.
    def remaining?
      remaining_count > 0
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
