require "./node_filter"

module Spectator
  # Filter that matches nodes based on their name.
  class NameNodeFilter < NodeFilter
    # Creates the node filter.
    def initialize(@name : String)
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      node.to_s.includes?(@name)
    end
  end
end
