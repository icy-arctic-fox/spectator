require "./formatter"
require "colorize"

module Spectator
  module Formatters
    class DefaultFormatter < Formatter
      def start_suite
      end

      def end_suite(results : TestResults)
        puts
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
    end
  end
end
