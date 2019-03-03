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
      # TODO: Condense similar parents.
      current_group = example.group
      group_list = [] of NestedExampleGroup
      while current_group.is_a?(NestedExampleGroup)
        group_list << current_group
        current_group = current_group.parent
      end
      indent = 0
      group_list.reverse_each do |group|
        indent.times { @io.print ' ' }
        @io.puts group.what
        indent += 2
      end
    end

    # Produces a single character output based on a result.
    def end_example(result)
      # TODO: Indent.
      @io.puts result.call(Color) { result.example.what }
    end
  end
end
