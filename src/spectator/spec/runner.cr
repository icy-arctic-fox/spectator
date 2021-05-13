require "../example"
require "../run_flags"

module Spectator
  class Spec
    # Logic for executing examples and collecting results.
    private struct Runner
      # Creates the runner.
      # The collection of *examples* should be pre-filtered and shuffled.
      # This runner will run each example in the order provided.
      def initialize(@examples : Enumerable(Example), @run_flags = RunFlags::None)
      end

      # Runs the spec.
      # This will run the provided examples
      # and invoke the reporters to communicate results.
      # True will be returned if the spec ran successfully,
      # or false if there was at least one failure.
      def run : Bool
        executed = [] of Example
        elapsed = Time.measure { executed = run_examples }

        # TODO: Generate a report and pass it along to the formatter.

        false # TODO: Report real result
      end

      # Attempts to run all examples.
      # Returns a list of examples that ran.
      private def run_examples
        Array(Example).new(example_count).tap do |executed|
          @examples.each do |example|
            result = run_example(example)
            executed << example

            # Bail out if the example failed
            # and configured to stop after the first failure.
            break fail_fast if fail_fast? && result.fail?
          end
        end
      end

      # Runs a single example and returns the result.
      # The formatter is given the example and result information.
      private def run_example(example)
        if dry_run?
          dry_run_result
        else
          example.run
        end
      end

      # Creates a fake result.
      private def dry_run_result
        expectations = [] of Expectation
        PassResult.new(Time::Span.zero, expectations)
      end

      # Generates and returns a profile if one should be displayed.
      private def profile(report)
        Profile.generate(report) if @config.profile?
      end

      # Indicates whether examples should be simulated, but not run.
      private def dry_run?
        @run_flags.dry_run?
      end

      # Indicates whether test execution should stop after the first failure.
      private def fail_fast?
        @run_flags.fail_fast?
      end

      private def fail_fast : Nil
      end

      # Number of examples configured to run.
      private def example_count
        @examples.size
      end
    end
  end
end
