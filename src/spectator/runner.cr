module Spectator
  class Runner
    def initialize(@group : ExampleGroup,
      @formatter : Formatters::Formatter = Formatters::DefaultFormatter.new)
    end

    def run : Nil
      results = [] of Result
      elapsed = Time.measure do
        @formatter.start_suite
        results = @group.all_examples.map do |example|
          @formatter.start_example(example)
          example.run.tap do |result|
            @formatter.end_example(result)
          end
        end
      end
      @formatter.end_suite(TestResults.new(results, elapsed))
    end
  end
end
