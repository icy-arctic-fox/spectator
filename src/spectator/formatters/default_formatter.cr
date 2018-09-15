require "./formatter"
require "colorize"

module Spectator
  module Formatters
    class DefaultFormatter < Formatter
      def start_suite
      end

      def end_suite(report : Report)
        puts
      end

      def start_example(example : Example)
      end

      def end_example(result : ExampleResult)
        print case result
        when SuccessfulExampleResult
          ".".colorize.green
        when PendingExampleResult
          "P".colorize.yellow
        when ErroredExampleResult
          "E".colorize.magenta
        when FailedExampleResult
          "F".colorize.red
        end
      end
    end
  end
end
