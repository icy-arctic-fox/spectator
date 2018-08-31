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
      example.run
      SuccessfulExampleResult.new(example)
    rescue failure : ExpectationFailedError
      FailedExampleResult.new(example, failure)
    rescue ex
      ErroredExampleResult.new(example, ex)
    end
  end
end
