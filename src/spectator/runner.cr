require "./failed_example_result"
require "./successful_example_result"

module Spectator
  class Runner
    getter results : Enumerable(ExampleResult)

    def initialize(@examples : Enumerable(Example))
      @results = Array(ExampleResult).new(@examples.size)
    end

    def run : Nil
      @examples.each do |example|
        result = run_example(example)
        pp result
      end
    end

    private def run_example(example)
      example.run
      SuccessfulExampleResult.new(example)
    rescue
      FailedExampleResult.new(example)
    end
  end
end
