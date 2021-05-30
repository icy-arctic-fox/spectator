require "./result"

module Spectator
  # Outcome of all tests in a suite.
  class Report
    # Records the number of examples that had each type of result.
    record Counts, pass = 0, fail = 0, error = 0, pending = 0, remaining = 0 do
      # Number of examples that actually ran.
      def run
        pass + fail + pending
      end

      # Total number of examples in the suite that were selected to run.
      def total
        run + remaining
      end

      # Indicates whether there were skipped tests
      # because of a failure causing the test suite to abort.
      def remaining?
        remaining > 0
      end
    end

    # Retrieves all examples that were planned to run as part of the suite.
    getter examples : Array(Example)

    # Total length of time it took to execute the test suite.
    # This includes examples, hooks, and framework processes.
    getter runtime : Time::Span

    # Number of examples of each result type.
    getter counts : Counts

    # Seed used for random number generation.
    getter! random_seed : UInt64?

    # Creates the report.
    # The *examples* are all examples in the test suite that were selected to run.
    # The *runtime* is the total time it took to execute the suite.
    # The *counts* is the number of examples for each type of result.
    # The *random_seed* is the seed used for random number generation.
    def initialize(@examples : Array(Example), @runtime, @counts : Counts, @random_seed = nil)
    end

    # Generates the report from a set of examples.
    def self.generate(examples : Enumerable(Example), runtime, random_seed = nil)
      counts = count_examples(examples)
      new(examples.to_a, runtime, counts, random_seed)
    end

    # Counts the number of examples for each result type.
    private def self.count_examples(examples)
      visitor = CountVisitor.new

      # Number of tests not run.
      remaining = 0

      # Iterate through each example and count the number of each type of result.
      # If an example hasn't run (indicated by `Node#finished?`), then count is as "remaining."
      # This typically happens in fail-fast mode.
      examples.each do |example|
        if example.finished?
          example.result.accept(visitor)
        else
          remaining += 1
        end
      end

      visitor.counts(remaining)
    end

    # Returns a collection of all failed examples.
    def failures
      @examples.select(&.result.fail?)
    end

    # Returns a collection of all pending (skipped) examples.
    def pending
      @examples.select(&.result.pending?)
    end

    # Length of time it took to run just example code.
    # This does not include hooks,
    # but it does include pre- and post-conditions.
    def example_runtime
      @examples.sum(&.result.elapsed)
    end

    # Length of time spent in framework processes and hooks.
    def overhead_time
      @runtime - example_runtime
    end

    # Totals up the number of each type of result.
    # Defines methods for the different types of results.
    # Call `#counts` to retrieve the `Counts` instance.
    private class CountVisitor
      @pass = 0
      @fail = 0
      @error = 0
      @pending = 0

      # Increments the number of passing examples.
      def pass(_result)
        @pass += 1
      end

      # Increments the number of failing (non-error) examples.
      def fail(_result)
        @fail += 1
      end

      # Increments the number of error (and failed) examples.
      def error(result)
        fail(result)
        @error += 1
      end

      # Increments the number of pending (skipped) examples.
      def pending(_result)
        @pending += 1
      end

      # Produces the total counts.
      # The *remaining* number of examples should be provided.
      def counts(remaining)
        Counts.new(@pass, @fail, @error, @pending, remaining)
      end
    end
  end
end
