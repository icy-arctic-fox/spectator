require "./formatter"
require "./suite_summary"

module Spectator::Formatters
  # Produces a single character for each example.
  # A dot is output for each successful example (hence the name).
  # Other characters are output for non-successful results.
  # At the end of the test suite, a summary of failures and results is displayed.
  class DotsFormatter < Formatter
    include SuiteSummary
    include Color

    # Character output for a successful example.
    SUCCESS_CHAR = '.'

    # Character output for a failed example.
    FAILURE_CHAR = 'F'

    # Character output for an errored example.
    ERROR_CHAR = 'E'

    # Character output for a pending or skipped example.
    PENDING_CHAR = '*'

    # Does nothing when an example is started.
    def start_example(example)
      # ...
    end

    # Produces a single character output based on a result.
    def end_example(result)
      case result
      when ErroredResult
        print error(ERROR_CHAR)
      when PendingResult
        print pending(PENDING_CHAR)
      when SuccessfulResult
        print success(SUCCESS_CHAR)
      else # FailedResult
        print failure(FAILURE_CHAR)
      end
    end
  end
end
