module Spectator
  # Outcome of all tests in a suite.
  class TestSuiteResults
    getter runtime : Time::Span

    @results : Array(Result)

    def initialize(results : Enumerable(Result), @runtime)
      @results = results.to_a
    end

    def examples
      @results.size
    end

    def successful_examples
      @results.count(&.successful?)
    end

    def failed_examples
      @results.count(&.failed?)
    end

    def failures
      @results.select(&.failed?)
    end

    def errored_examples
      @results.count(&.errored?)
    end

    def errors
      @results.select(&.errored?)
    end

    def pending_examples
      @results.count(&.pending?)
    end

    def example_runtime
      @results.map(&.elapsed).sum
    end

    def overhead_time
      @runtime - example_runtime
    end
  end
end
