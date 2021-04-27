require "./result"

module Spectator
  # Outcome of all tests in a suite.
  class Report
    include Enumerable(Example)

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

    # Random seed used to determine test ordering.
    getter! random_seed : UInt64?

    # Creates the report.
    # The *examples* are all examples in the test suite.
    # The *runtime* is the total time it took to execute the suite.
    # The *remaining_count* is the number of tests skipped due to fail-fast.
    # The *fail_blank* flag indicates whether it is a failure if there were no tests run.
    # The *random_seed* is the seed used for random number generation.
    def initialize(@examples : Array(Example), @runtime, @remaining_count = 0, @fail_blank = false, @random_seed = nil)
      @examples.each do |example|
        case example.result
        when PassResult
          @successful_count += 1
        when ErrorResult
          @error_count += 1
          @failed_count += 1
        when FailResult
          @failed_count += 1
        when PendingResult
          @pending_count += 1
        when Result
          # This case isn't possible, but gets the compiler to stop complaining.
          nil
        end
      end
    end

    # Creates the report.
    # This constructor is intended for reports of subsets of results.
    # The *examples* are all examples in the test suite.
    # The runtime is calculated from the *results*.
    def initialize(examples : Array(Example))
      runtime = examples.sum(&.result.elapsed)
      initialize(examples, runtime)
    end

    # Yields each example in turn.
    def each
      @examples.each do |example|
        yield example
      end
    end

    # Retrieves results of all examples.
    def results
      @examples.each.map(&.result)
    end

    # Number of examples.
    def example_count
      @examples.size
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

    # Returns a set of all failed examples.
    def failures
      @examples.select(&.result.is_a?(FailResult))
    end

    # Returns a set of all errored examples.
    def errors
      @examples.select(&.result.is_a?(ErrorResult))
    end

    # Length of time it took to run just example code.
    # This does not include hooks,
    # but it does include pre- and post-conditions.
    def example_runtime
      results.sum(&.elapsed)
    end

    # Length of time spent in framework processes and hooks.
    def overhead_time
      @runtime - example_runtime
    end
  end
end
