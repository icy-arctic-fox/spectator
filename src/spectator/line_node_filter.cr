require "./node_filter"

module Spectator
  # Filter that matches nodes on a given line.
  class LineNodeFilter < NodeFilter
    # Creates the node filter.
    def initialize(@line : Int32)
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      return false unless location = node.location?

      start_line = location.line
      end_line = location.end_line
      (start_line..end_line).covers?(@line)
    end
  end
end
