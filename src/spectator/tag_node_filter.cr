require "./node_filter"

module Spectator
  # Filter that matches nodes with a given tag.
  class TagNodeFilter < NodeFilter
    # Creates the filter.
    # The *tag* indicates which tag the node must have in its metadata.
    def initialize(@tag : String)
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      node.metadata.each_key.any? { |key| key.to_s == @tag }
    end
  end
end
