require "./formatter"
require "colorize"

module Spectator
  module Formatters
    class DefaultFormatter < Formatter
      SUCCESS_COLOR = :green
      FAILURE_COLOR = :red
      ERROR_COLOR   = :magenta
      PENDING_COLOR = :yellow

      SUCCESS_CHAR = '.'.colorize(SUCCESS_COLOR)
      FAILURE_CHAR = 'F'.colorize(FAILURE_COLOR)
      ERROR_CHAR   = 'E'.colorize(ERROR_COLOR)
      PENDING_CHAR = 'P'.colorize(PENDING_COLOR)

      def start_suite
      end

      def end_suite(results : TestResults)
        puts
        puts
        puts finish_time_string(results)
        puts result_string(results)
      end

      def start_example(example : Example)
      end

      def end_example(result : Result)
        print result_char(result)
      end

      private def result_char(result : Result)
        case result
        when SuccessfulResult
          SUCCESS_CHAR
        when PendingResult
          PENDING_CHAR
        when ErroredResult
          ERROR_CHAR
        when FailedResult
          FAILURE_CHAR
        end
      end

      private def finish_time_string(results)
        "Finished in #{human_time(results.runtime)}"
      end

      private def result_string(results)
        examples = results.examples
        failures = results.failed_examples
        errors = results.errored_examples
        pending = results.pending_examples
        string = "#{examples} examples, #{failures} failures, #{errors} errors, #{pending} pending"
        if failures > 0 || errors > 0
          string.colorize(FAILURE_COLOR)
        elsif pending != examples
          string.colorize(PENDING_COLOR)
        else
          string.colorize(SUCCESS_COLOR)
        end
      end

      private def human_time(span : Time::Span)
        span.to_s
      end
    end
  end
end
