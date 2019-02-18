require "./formatter"
require "./suite_summary"

module Spectator::Formatters
  # Produces a single character for each example.
  # A dot is output for each successful example (hence the name).
  # Other characters are output for non-successful results.
  # At the end of the test suite, a summary of failures and results is displayed.
  class DotsFormatter < Formatter
    include SuiteSummary

    # Creates the formatter.
    # By default, output is sent to `STDOUT`.
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

      # Character output for a successful example.
      def success(result)
        Color.success('.')
      end

      # Character output for a failed example.
      def failure(result)
        Color.failure('F')
      end

      # Character output for an errored example.
      def error(result)
        Color.error('E')
      end

      # Character output for a pending or skipped example.
      def pending(result)
        Color.pending('*')
      end
    end
  end
end
