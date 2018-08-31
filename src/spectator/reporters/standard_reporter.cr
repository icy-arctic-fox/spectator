require "./reporter"
require "colorize"

module Spectator
  module Reporters
    class StandardReporter < Reporter
      def start_suite
      end

      def end_suite
        puts
      end

      def start_example(example : Example)
      end

      def end_example(result : ExampleResult)
        print case result
        when SuccessfulExampleResult
          ".".colorize.green
        when ErroredExampleResult
          "E".colorize.magenta
        when FailedExampleResult
          "F".colorize.red
        end
      end
    end
  end
end
