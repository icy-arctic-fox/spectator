require "../example"

module Spectator
  class Spec
    # Logic for executing examples and collecting results.
    private struct Runner
      # Creates the runner.
      # The collection of *examples* should be pre-filtered and shuffled.
      # This runner will run each example in the order provided.
      def initialize(@examples : Enumerable(Example), @config : Config)
      end

      # Runs the spec.
      # This will run the provided examples
      # and invoke the reporters to communicate results.
      # True will be returned if the spec ran successfully,
      # or false if there was at least one failure.
      def run : Bool
        # Indicate the suite is starting.
        @config.each_formatter(&.start_suite(@suite))

        # Run all examples and capture the results.
        examples = Array(Example).new(@suite.size)
        elapsed = Time.measure do
          collect_results(examples)
        end

        # Generate a report and pass it along to the formatter.
        remaining = @suite.size - examples.size
        seed = (@config.random_seed if @config.randomize?)
        report = Report.new(examples, elapsed, remaining, @config.fail_blank?, seed)
        @config.each_formatter(&.end_suite(report, profile(report)))

        !report.failed?
      end

      # Runs all examples and adds them to a list.
      private def collect_results(examples)
        example_order.each do |example|
          result = run_example(example)
          examples << example
          if @config.fail_fast? && result.is_a?(FailResult)
            example.group.call_once_after_all
            break
          end
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
        @config.each_formatter(&.end_example(example))
        result
      end

      # Creates a fake result for an example.
      private def dry_run_result(example)
        expectations = [] of Expectation
        PassResult.new(Time::Span.zero, expectations)
      end

      # Generates and returns a profile if one should be displayed.
      private def profile(report)
        Profile.generate(report) if @config.profile?
      end
    end
  end
end
