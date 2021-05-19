require "../label"
require "./formatter"
require "./summary"

module Spectator::Formatting
  # Produces an indented document-style output.
  # Each nested group of examples increases the indent.
  # Example names are output in a color based on their result.
  class DocumentFormatter < Formatter
    include Summary

    # Identation string.
    private INDENT = "  "

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
      line(notification.example.name.colorize(:green))
    end

    # Invoked after an example is skipped or marked as pending.
    # Produces a pending example line.
    def example_pending(notification)
      line(notification.example.name.colorize(:yellow))
    end

    # Invoked after an example fails.
    # Produces a failure example line.
    def example_failed(notification)
      line(notification.example.name.colorize(:red))
    end

    # Invoked after an example fails from an unexpected error.
    # Produces a failure example line.
    def example_error(notification)
      example_failed(notification)
    end

    # Produces a list of groups making up the hierarchy for an example.
    private def group_hierarchy(example)
      Array(Label).new.tap do |hierarchy|
        group = example.group?
        while group && (parent = group.group?)
          hierarchy << group.name
          group = parent
        end
        hierarchy.reverse!
      end
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
    private def print_sub_hierarchy(start_index, hierarchy)
      hierarchy.each_with_index(start_index) do |name, index|
        line(name, index)
      end
    end

    # Displays an indented line of text.
    private def line(text, level = @previous_hierarchy.size)
      level.times { @io << INDENT }
      @io.puts text
    end
  end
end
