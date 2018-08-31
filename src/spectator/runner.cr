require "./failed_example_result"
require "./successful_example_result"

module Spectator
  class Runner
    def initialize(@examples : Enumerable(Example),
      @run_order : RunOrder = DefinedRunOrder.new,
      @reporter : Reporters::Reporter = Reporters::StandardReporter.new)
    end

    def run : Nil
      @reporter.start_suite
      sorted_examples.each do |example|
        @reporter.start_example(example)
        result = run_example(example)
        @reporter.end_example(result)
      end
      @reporter.end_suite
    end

    private def sorted_examples
      @examples.to_a.sort { |a, b| @run_order.sort(a, b) }
    end

    private def run_example(example)
      error = nil
      elapsed = Time.measure do
        begin
          example.run
        rescue failure : ExpectationFailedError
          error = failure
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
