require "./formatter"
require "./suite_summary"

module Spectator::Formatting
  # Produces a single character for each example.
  # A dot is output for each successful example (hence the name).
  # Other characters are output for non-successful results.
  # At the end of the test suite, a summary of failures and results is displayed.
  class DotsFormatter < Formatter
    include SuiteSummary

    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(@io : IO = STDOUT)
    end

    # Does nothing when an example is started.
    def start_example(example)
      # ...
    end

    # Produces a single character output based on a result.
    def end_example(result)
      @io.print result.call(Character)
    end

    # Interface for `Result` to pick a character for output.
    private module Character
      extend self

      # Characters for each of the result types.
      private CHARACTERS = {
        success: '.',
        failure: 'F',
        error:   'E',
        pending: '*',
      }

      # Character output for a successful example.
      def success
        Color.success(CHARACTERS[:success])
      end

      # Character output for a failed example.
      def failure
        Color.failure(CHARACTERS[:failure])
      end

      # Character output for an errored example.
      def error
        Color.error(CHARACTERS[:error])
      end

      # Character output for a pending or skipped example.
      def pending
        Color.pending(CHARACTERS[:pending])
      end
    end
  end
end
