require "./example"
require "./node"
require "./node_filter"
require "./node_iterator"

module Spectator
  # Iterates through selected nodes in a group and its nested groups.
  # Nodes are iterated in pre-order.
  class FilteredExampleIterator
    include Iterator(Example)

    # A stack is used to track where in the tree this iterator is.
    @stack = Deque(Node).new(1)

    # A queue stores forced examples that have been matched by the a parent group.
    @queue = Deque(Example).new

    # Creates a new iterator.
    # The *group* is the example group to iterate through.
    # The *filter* selects which examples (and groups) to iterate through.
    def initialize(@group : Node, @filter : NodeFilter)
      @stack.push(@group)
    end

    # Retrieves the next selected `Example`.
    # If there are none left, then `Iterator::Stop` is returned.
    def next
      # Return items from the queue first before continuing to the stack.
      return @queue.shift unless @queue.empty?

      # Keep going until either:
      # a. a suitable example is found.
      # b. the stack is empty.
      until @stack.empty?
        # Retrieve the next node.
        node = @stack.pop

        # If the node is a group, conditionally traverse it.
        if node.is_a?(Indexable(Node))
          # To traverse, a child node or the group itself must match the filter.
          return node if node = next_group_match(node)
        elsif node.is_a?(Example) && @filter.includes?(node)
          return node
        end
      end

      # Nothing left to iterate.
      stop
    end

    # Restart the iterator at the beginning.
    def rewind
      @stack.clear
      @stack.push(@group)
      @queue.clear
      self
    end

    # Attempts to find the next matching example in a group.
    # If any child in the group matches, then traversal on the stack (down the tree) continues.
    # However, if no children match, but the group itself does, then all examples in the group match.
    # In the latter scenario, the examples are added to the queue, and the next item from the queue returned.
    # Stack iteration should continue if nil is returned.
    private def next_group_match(group : Indexable(Node)) : Example?
      # Look for any children that match.
      iterator = NodeIterator.new(group)

      # Check if any children match.
      # Skip first node because its the group being checked.
      if iterator.skip(1).any?(@filter)
        # Add the group's direct children to the queue
        # in reverse order so that the tree is traversed in pre-order.
        group.reverse_each { |node| @stack.push(node) }

        # Check if the group matches, but no children match.
      elsif @filter.includes?(group)
        # Add examples from the group to the queue.
        # Return the next example from the queue.
        iterator.rewind.select(Example).each { |node| @queue.push(node) }
        @queue.shift unless @queue.empty?
        # If the queue is empty (group has no examples), go to next loop iteration of the stack.
      end
    end
  end
end
