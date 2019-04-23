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
      @config.each_formatter(&.start_suite(@suite))

      # Run all examples and capture the results.
      results = Array(Result).new(@suite.size)
      elapsed = Time.measure do
        collect_results(results)
      end

      # Generate a report and pass it along to the formatter.
      remaining = @suite.size - results.size
      report = Report.new(results, elapsed, remaining, @config.fail_blank?)
      @config.each_formatter(&.end_suite(report, profile(report)))

      !report.failed?
    end

    # Runs all examples and adds results to a list.
    private def collect_results(results)
      example_order.each do |example|
        result = run_example(example).as(Result)
        results << result
        if @config.fail_fast? && result.is_a?(FailedResult)
          example.group.run_after_all_hooks(ignore_unfinished: true)
          break
        end
      end
    end

    # Retrieves an enumerable for the examples to run.
    # The order of examples is randomized
    # if specified by the configuration.
    private def example_order
      @suite.to_a.tap do |examples|
        examples.shuffle!(@config.random) if @config.randomize?
      end
    end

    # Runs a single example and returns the result.
    # The formatter is given the example and result information.
    private def run_example(example)
      @config.each_formatter(&.start_example(example))
      result = if @config.dry_run? && example.is_a?(RunnableExample)
                 dry_run_result(example)
               else
                 Internals::Harness.run(example)
               end
      @config.each_formatter(&.end_example(result))
      result
    end

    # Creates a fake result for an example.
    private def dry_run_result(example)
      expectations = [] of Expectations::Expectation
      example_expectations = Expectations::ExampleExpectations.new(expectations)
      SuccessfulResult.new(example, Time::Span.zero, example_expectations)
    end

    # Generates and returns a profile if one should be displayed.
    private def profile(report)
      Profile.generate(report) if @config.profile?
    end
  end
end
