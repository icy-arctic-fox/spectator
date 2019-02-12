module Spectator
  # Main driver for executing tests and feeding results to formatters.
  class Runner
    # Creates the test suite runner.
    # Specify the test `suite` to run and any additonal configuration.
    def initialize(@suite : TestSuite, @config : Config)
    end

    # Runs the test suite.
    # This will run the selected examples
    # and invoke the formatter to output results.
    def run : Nil
      # Indicate the suite is starting.
      @config.formatter.start_suite(@suite)

      # Run all examples and capture the results.
      results = [] of Result
      elapsed = Time.measure do
        results = @suite.map do |example|
          run_example(example).as(Result)
        end
      end

      # Generate a report and pass it along to the formatter.
      report = Report.new(results, elapsed)
      @config.formatter.end_suite(report)
    end

    # Runs a single example and returns the result.
    # The formatter is given the example and result information.
    private def run_example(example) : Result
      @config.formatter.start_example(example)
      Internals::Harness.run(example).tap do |result|
        @config.formatter.end_example(result)
      end
    end
  end
end
