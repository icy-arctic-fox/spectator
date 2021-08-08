require "./node_filter"

module Spectator
  # Filter that matches all nodes.
  class NullNodeFilter < NodeFilter
    # Checks whether the node satisfies the filter.
    def includes?(_node) : Bool
      true
    end
  end
end
