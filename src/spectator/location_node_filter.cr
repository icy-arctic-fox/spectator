require "./location"
require "./node_filter"

module Spectator
  # Filter that matches nodes in a given file and line.
  class LocationNodeFilter < NodeFilter
    # Creates the filter.
    # The *location* indicates which file and line the node must contain.
    def initialize(@location : Location)
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      @location === node.location?
    end
  end
end
