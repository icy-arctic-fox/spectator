require "./events"
require "./spec_node"

module Spectator
  # Collection of examples and sub-groups.
  class ExampleGroup < SpecNode
    include Enumerable(SpecNode)
    include Events
    include Iterable(SpecNode)

    group_event before_all do |hooks|
      Log.trace { "Processing before_all hooks" }

      if (parent = group?)
        parent.call_once_before_all
      end

      hooks.each(&.call)
    end

    group_event after_all do |hooks|
      Log.trace { "Processing after_all hooks" }

      hooks.each(&.call)

      if (parent = group?)
        parent.call_once_after_all
      end
    end

    example_event before_each do |hooks, example|
      Log.trace { "Processing before_each hooks" }

      if (parent = group?)
        parent.call_before_each(example)
      end

      hooks.each(&.call(example))
    end

    example_event after_each do |hooks, example|
      Log.trace { "Processing after_each hooks" }

      hooks.each(&.call(example))

      if (parent = group?)
        parent.call_after_each(example)
      end
    end

    @nodes = [] of SpecNode

    # Removes the specified *node* from the group.
    # The node will be unassigned from this group.
    def delete(node : SpecNode)
      # Only remove from the group if it is associated with this group.
      return unless node.group == self

      node.group = nil
      @nodes.delete(node)
    end

    # Yields each node (example and sub-group).
    def each
      @nodes.each { |node| yield node }
    end

    # Returns an iterator for each (example and sub-group).
    def each
      @nodes.each
    end

    # Checks if all examples and sub-groups have finished.
    def finished? : Bool
      @nodes.all?(&.finished?)
    end

    # Adds the specified *node* to the group.
    # Assigns the node to this group.
    # If the node already belongs to a group,
    # it will be removed from the previous group before adding it to this group.
    def <<(node : SpecNode)
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
