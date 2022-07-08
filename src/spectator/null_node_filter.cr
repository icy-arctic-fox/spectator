require "./node_filter"

module Spectator
  # Filter that matches all nodes.
  class NullNodeFilter < NodeFilter
    # Creates the filter.
    # The *match* flag indicates whether all examples should match or not.
    def initialize(@match : Bool = true)
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      @match
    end
  end
end
