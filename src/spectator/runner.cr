require "./failed_example_result"
require "./successful_example_result"

module Spectator
  class Runner
    def initialize(@group : ExampleGroup,
      @formatter : Formatters::Formatter = Formatters::StandardFormatter.new)
    end

    def run : Nil
      results = [] of ExampleResult
      elapsed = Time.measure do
        @formatter.start_suite
        results = @group.all_examples.map do |example|
          @formatter.start_example(example)
          example.run.tap do |result|
            @formatter.end_example(result)
          end
        end
      end
      report = Report.new(results, elapsed)
      @formatter.end_suite(report)
    end
  end
end
