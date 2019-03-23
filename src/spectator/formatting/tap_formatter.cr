module Spectator::Formatting
  # Formatter for the "Test Anything Protocol".
  # For details, see: https://testanything.org/
  class TAPFormatter < Formatter
    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(@io : IO = STDOUT)
      @index = 1
    end

    # Called when a test suite is starting to execute.
    def start_suite(suite : TestSuite)
      @io << "1.."
      @io.puts suite.size
    end

    # Called when a test suite finishes.
    # The results from the entire suite are provided.
    def end_suite(report : Report)
      @io.puts "Bail out!" if report.remaining?
    end

    # Called before a test starts.
    def start_example(example : Example)
    end

    # Called when a test finishes.
    # The result of the test is provided.
    def end_example(result : Result)
      @io.puts TAPTestLine.new(@index, result)
      @index += 1
    end
  end
end
