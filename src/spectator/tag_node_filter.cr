require "./node_filter"

module Spectator
  # Filter that matches nodes with a given tag.
  class TagNodeFilter < NodeFilter
    # Creates the filter.
    # The *tag* indicates which tag the node must have in its metadata.
    def initialize(@tag : String, @value : String? = nil)
    end

    # Checks whether the node satisfies the filter.
    def includes?(node) : Bool
      return false unless metadata = node.metadata

      metadata.any? { |key, value| key.to_s == @tag && (!@value || value == @value) }
    end
  end
end
