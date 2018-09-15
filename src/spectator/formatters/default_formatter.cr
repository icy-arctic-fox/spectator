require "./formatter"
require "colorize"

module Spectator
  module Formatters
    class DefaultFormatter < Formatter
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
        print case result
        when SuccessfulResult
          ".".colorize.green
        when PendingResult
          "P".colorize.yellow
        when ErroredResult
          "E".colorize.magenta
        when FailedResult
          "F".colorize.red
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
        "#{examples} examples, #{failures} failures, #{errors} errors, #{pending} pending"
      end

      private def human_time(span : Time::Span)
        span.to_s
      end
    end
  end
end
