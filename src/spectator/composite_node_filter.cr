require "./node_filter"

module Spectator
  # Filter that combines multiple other filters.
  class CompositeNodeFilter < NodeFilter
    # Creates the example filter.
    def initialize(@filters : Array(NodeFilter))
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      @filters.any?(&.includes?(node))
    end
  end
end
