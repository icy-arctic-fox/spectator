require "./failed_example_result"
require "./successful_example_result"

module Spectator
  class Runner
    def initialize(@examples : Enumerable(Example), @run_order : RunOrder)
    end

    def run : Nil
      sorted_examples.each do |example|
        result = run_example(example)
        pp result
      end
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
