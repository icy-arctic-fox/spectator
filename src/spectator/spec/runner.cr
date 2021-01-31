require "../example"

module Spectator
  class Spec
    private struct Runner
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
        seed = (@config.random_seed if @config.randomize?)
        report = Report.new(results, elapsed, remaining, @config.fail_blank?, seed)
        @config.each_formatter(&.end_suite(report, profile(report)))

        !report.failed?
      end

      # Runs all examples and adds results to a list.
      private def collect_results(results)
        example_order.each do |example|
          result = run_example(example).as(Result)
          results << result
          if @config.fail_fast? && result.is_a?(FailResult)
            example.group.call_once_after_all
            break
          end
        end
      end

      # Retrieves an enumerable for the examples to run.
      # The order of examples is randomized
      # if specified by the configuration.
      private def example_order
        @suite.to_a.tap do |examples|
          @config.shuffle!(examples)
        end
      end

      # Runs a single example and returns the result.
      # The formatter is given the example and result information.
      private def run_example(example)
        @config.each_formatter(&.start_example(example))
        result = if @config.dry_run?
                   dry_run_result(example)
                 else
                   example.run
                 end
        @config.each_formatter(&.end_example(result))
        result
      end

      # Creates a fake result for an example.
      private def dry_run_result(example)
        expectations = [] of Expectation
        PassResult.new(example, Time::Span.zero, expectations)
      end

      # Generates and returns a profile if one should be displayed.
      private def profile(report)
        Profile.generate(report) if @config.profile?
      end
    end
  end
end
