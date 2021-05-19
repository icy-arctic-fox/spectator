require "../label"
require "./formatter"
require "./summary"

module Spectator::Formatting
  # Produces an indented document-style output.
  # Each nested group of examples increases the indent.
  # Example names are output in a color based on their result.
  class DocumentFormatter < Formatter
    include Summary

    # Whitespace count per indent.
    private INDENT_AMOUNT = 2

    # Output stream to write results to.
    private getter io

    @previous_hierarchy = [] of Label

    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(@io : IO = STDOUT)
    end

    # Invoked just before an example runs.
    # Prints the example group hierarchy if it changed.
    def example_started(notification)
      hierarchy = group_hierarchy(notification.example)
      tuple = hierarchy_diff(@previous_hierarchy, hierarchy)
      print_sub_hierarchy(*tuple)
      @previous_hierarchy = hierarchy
    end

    # Invoked after an example completes successfully.
    # Produces a successful example line.
    def example_passed(notification)
      indent = @previous_hierarchy.size * INDENT_AMOUNT
      indent.times { @io << ' ' }
      @io.puts notification.example.name.colorize(:green)
    end

    # Invoked after an example is skipped or marked as pending.
    # Produces a pending example line.
    def example_pending(notification)
      indent = @previous_hierarchy.size * INDENT_AMOUNT
      indent.times { @io << ' ' }
      @io.puts notification.example.name.colorize(:yellow)
    end

    # Invoked after an example fails.
    # Produces a failure example line.
    def example_failed(notification)
      indent = @previous_hierarchy.size * INDENT_AMOUNT
      indent.times { @io << ' ' }
      @io.puts notification.example.name.colorize(:red)
    end

    # Invoked after an example fails from an unexpected error.
    # Produces a failure example line.
    def example_error(notification)
      example_failed(notification)
    end

    # Produces a list of groups making up the hierarchy for an example.
    private def group_hierarchy(example)
      hierarchy = [] of Label
      group = example.group?
      while group && (parent = group.group?)
        hierarchy << group.name
        group = parent
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
    private def print_sub_hierarchy(start_index, sub_hierarchy)
      sub_hierarchy.each_with_index(start_index) do |name, index|
        (index * INDENT_AMOUNT).times { @io << ' ' }
        @io.puts name
      end
    end
  end
end
