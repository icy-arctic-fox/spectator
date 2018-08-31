require "./failed_example_result"
require "./successful_example_result"

module Spectator
  class Runner
    def initialize(@examples : Enumerable(Example),
      @run_order : RunOrder = DefinedRunOrder.new,
      @reporter : Reporters::Reporter = Reporters::StandardReporter.new)
    end

    def run : Nil
      results = [] of ExampleResult
      elapsed = Time.measure do
        @reporter.start_suite
        results = sorted_examples.map do |example|
          @reporter.start_example(example)
          run_example(example).tap do |result|
            @reporter.end_example(result)
          end
        end
      end
      report = Report.new(results, elapsed)
      @reporter.end_suite(report)
    end

    private def sorted_examples
      @examples.to_a.sort { |a, b| @run_order.sort(a, b) }
    end

    private def run_example(example)
      error = nil
      elapsed = Time.measure do
        begin
          example.run
        rescue ex
          error = ex
        end
      end
      case error
      when Nil
        SuccessfulExampleResult.new(example, elapsed)
      when ExpectationFailedError
        FailedExampleResult.new(example, elapsed, error)
      else
        ErroredExampleResult.new(example, elapsed, error)
      end
    end
  end
end
