module Spectator
  # Main driver for executing tests and feeding results to formatters.
  class Runner
    # Creates the test suite runner.
    # Specify the test *suite* to run and any additonal configuration.
    def initialize(@suite : TestSuite, @config : Config)
    end

    # Runs the test suite.
    # This will run the selected examples
    # and invoke the formatter to output results.
    # True will be returned if the test suite ran successfully,
    # or false if there was at least one failure.
    def run : Bool
      # Indicate the suite is starting.
      @config.formatter.start_suite(@suite)

      # Run all examples and capture the results.
      results = Array(Result).new(@suite.size)
      elapsed = Time.measure do
        collect_results(results)
      end

      # Generate a report and pass it along to the formatter.
      remaining = @suite.size - results.size
      report = Report.new(results, elapsed, remaining)
      @config.formatter.end_suite(report)

      !report.failed?
    end

    # Runs all examples and adds results to a list.
    private def collect_results(results)
      @suite.each do |example|
        result = run_example(example).as(Result)
        results << result
        break if @config.fail_fast? && result.is_a?(FailedResult)
      end
    end

    # Runs a single example and returns the result.
    # The formatter is given the example and result information.
    private def run_example(example)
      @config.formatter.start_example(example)
      Internals::Harness.run(example).tap do |result|
        @config.formatter.end_example(result)
      end
    end
  end
end
