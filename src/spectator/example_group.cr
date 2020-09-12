require "./example_node"

module Spectator
  # Collection of examples and sub-groups.
  class ExampleGroup < ExampleNode
    include Enumerable(ExampleNode)

    @nodes = [] of ExampleNode

    # Removes the specified *node* from the group.
    # The node will be unassigned from this group.
    def delete(node : ExampleNode)
      # Only remove from the group if it is associated with this group.
      return unless node.group == self

      node.group = nil
      @nodes.delete(node)
    end

    # Yields each node (example and sub-group).
    def each
      @nodes.each { |node| yield node }
    end

    # Checks if all examples and sub-groups have finished.
    def finished? : Bool
      @nodes.all?(&.finished?)
    end

    # Adds the specified *node* to the group.
    # Assigns the node to this group.
    # If the node already belongs to a group,
    # it will be removed from the previous group before adding it to this group.
    def <<(node : ExampleNode)
      # Remove from existing group if the node is part of one.
      if (previous = node.group?)
        previous.delete(node)
      end

      # Add the node to this group and associate with it.
      @nodes << node
      node.group = self
    end
  end
end
