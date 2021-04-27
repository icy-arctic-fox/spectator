require "../example_group"
require "./formatter"
require "./suite_summary"

module Spectator::Formatting
  # Produces an indented document-style output.
  # Each nested group of examples increases the indent.
  # Example names are output in a color based on their result.
  class DocumentFormatter < Formatter
    include SuiteSummary

    private INDENT = "  "

    @previous_hierarchy = [] of ExampleGroup

    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(@io : IO = STDOUT)
    end

    # Does nothing when an example is started.
    def start_example(example)
      hierarchy = group_hierarchy(example)
      tuple = hierarchy_diff(@previous_hierarchy, hierarchy)
      print_sub_hierarchy(*tuple)
      @previous_hierarchy = hierarchy
    end

    # Produces a single character output based on a result.
    def end_example(example)
      @previous_hierarchy.size.times { @io.print INDENT }
      @io.puts example.result.accept(Color) { example }
    end

    # Produces a list of groups making up the hierarchy for an example.
    private def group_hierarchy(example)
      hierarchy = [] of ExampleGroup
      group = example.group
      while group.is_a?(ExampleGroup)
        hierarchy << group if group.name?
        group = group.group?
      end
      hierarchy.reverse
    end

    # Generates a difference between two hierarchies.
    private def hierarchy_diff(first, second)
      index = -1
      diff = second.skip_while do |group|
        index += 1
        first.size > index && first[index] == group
      end
      {index, diff}
    end

    # Displays an indented hierarchy starting partially into the whole hierarchy.
    private def print_sub_hierarchy(index, sub_hierarchy)
      sub_hierarchy.each do |group|
        index.times { @io.print INDENT }
        @io.puts group.name
        index += 1
      end
    end
  end
end
