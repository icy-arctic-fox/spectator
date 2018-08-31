module Spectator
  class Report
    getter runtime : Time::Span

    @results : Array(ExampleResult)

    def initialize(results : Enumerable(ExampleResult), @runtime)
      @results = results.to_a
    end

    def successful_examples
      @results.select { |result| result.successful? }
    end

    def failed_examples
      @results.select { |result| result.failed? }
    end

    def example_runtime
      @results.map { |result| result.elapsed }.sum
    end

    def overhead_time
      @runtime - example_runtime
    end
  end
end
