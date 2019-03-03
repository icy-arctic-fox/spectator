require "./formatter"
require "./suite_summary"

module Spectator::Formatting
  # Produces an indented document-style output.
  # Each nested group of examples increases the indent.
  # Example names are output in a color based on their result.
  class DocumentFormatter < Formatter
    include SuiteSummary

    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(@io : IO = STDOUT)
    end

    # Does nothing when an example is started.
    def start_example(example)
      # TODO: Display group names.
    end

    # Produces a single character output based on a result.
    def end_example(result)
      @io.puts result.call(Color) { result.example.what }
    end
  end
end
