module Spectator
  # Base class for all node filters.
  # Checks whether a node should be included in the test run.
  # Sub-classes must implement the `#includes?` method.
  abstract class NodeFilter
    # Checks if a node is in the filter, and should be included in the test run.
    abstract def includes?(node) : Bool

    # :ditto:
    def ===(node)
      includes?(node)
    end
  end
end
