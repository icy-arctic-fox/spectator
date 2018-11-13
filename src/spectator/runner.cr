module Spectator
  class Runner
    def initialize(@group : ExampleGroup,
                   @formatter : Formatters::Formatter = Formatters::DefaultFormatter.new)
    end

    def run : Nil
      iterator = ExampleIterator.new(@group)
      results = [] of Result
      elapsed = Time.measure do
        @formatter.start_suite
        results = iterator.map do |example|
          @formatter.start_example(example)
          Internals::Harness.run(example).tap do |result|
            @formatter.end_example(result)
          end.as(Result)
        end.to_a
      end
      @formatter.end_suite(TestResults.new(results, elapsed))
    end
  end
end
