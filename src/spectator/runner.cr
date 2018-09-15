require "./failed_example_result"
require "./successful_example_result"

module Spectator
  class Runner
    def initialize(@group : ExampleGroup,
      @reporter : Reporters::Reporter = Reporters::StandardReporter.new)
    end

    def run : Nil
      results = [] of ExampleResult
      elapsed = Time.measure do
        @reporter.start_suite
        results = @group.all_examples.map do |example|
          @reporter.start_example(example)
          example.run.tap do |result|
            @reporter.end_example(result)
          end
        end
      end
      report = Report.new(results, elapsed)
      @reporter.end_suite(report)
    end
  end
end
