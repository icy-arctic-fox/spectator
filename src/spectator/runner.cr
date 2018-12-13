module Spectator
  # Main driver for executing tests and feeding results to formatters.
  class Runner
    def initialize(@suite : TestSuite, @config : Config)
    end

    def run : Nil
      results = [] of Result
      @config.formatter.start_suite
      elapsed = Time.measure do
        results = @suite.map do |example|
          run_example(example)
        end
      end
      @config.formatter.end_suite(TestSuiteResults.new(results, elapsed))
    end

    private def run_example(example)
      @config.formatter.start_example(example)
      result = Internals::Harness.run(example)
      @config.formatter.end_example(result)
      result
    end
  end
end
