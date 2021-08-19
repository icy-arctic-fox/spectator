require "./example"
require "./formatting/formatter"
require "./profile"
require "./report"
require "./run_flags"
require "./runner_events"

module Spectator
  # Logic for executing examples and collecting results.
  struct Runner
    include RunnerEvents

    # Formatter to send events to.
    private getter formatter : Formatting::Formatter

    # Creates the runner.
    # The collection of *examples* should be pre-filtered and shuffled.
    # This runner will run each example in the order provided.
    # The *formatter* will be called for various events.
    def initialize(@examples : Array(Example), @formatter : Formatting::Formatter,
                   @run_flags = RunFlags::None, @random_seed : UInt64? = nil)
    end

    # Runs the spec.
    # This will run the provided examples
    # and invoke the reporters to communicate results.
    # True will be returned if the spec ran successfully,
    # or false if there was at least one failure.
    def run : Bool
      start
      elapsed = Time.measure { run_examples }
      stop

      report = Report.generate(@examples, elapsed, @random_seed)
      profile = Profile.generate(@examples) if @run_flags.profile? && report.counts.run > 0
      summarize(report, profile)

      report.counts.fail.zero?
    ensure
      close
    end

    # Attempts to run all examples.
    # Returns a list of examples that ran.
    private def run_examples
      @examples.each do |example|
        result = run_example(example)

        # Bail out if the example failed
        # and configured to stop after the first failure.
        break fail_fast if fail_fast? && result.fail?
      end
    end

    # Runs a single example and returns the result.
    # The formatter is given the example and result information.
    private def run_example(example)
      example_started(example)
      result = if dry_run?
                 # TODO: Pending examples return a pending result instead of pass in RSpec dry-run.
                 dry_run_result
               else
                 example.run
               end
      example_finished(example)
      result
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
