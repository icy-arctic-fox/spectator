require "./node_filter"

module Spectator
  # Filter that matches nodes based on their name.
  class NameNodeFilter < NodeFilter
    # Creates the node filter.
    def initialize(@name : String)
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      @name == node.to_s
    end
  end
end
