require "./node"

module Spectator
  # Iterates through all nodes in a group and its nested groups.
  # Nodes are iterated in pre-order.
  class NodeIterator
    include Iterator(Node)

    # A stack is used to track where in the tree this iterator is.
    @stack = Deque(Node).new(1)

    # Creates a new iterator.
    # The *group* is the example group to iterate through.
    def initialize(@group : Node)
      @stack.push(@group)
    end

    # Retrieves the next `Node`.
    # If there are none left, then `Iterator::Stop` is returned.
    def next
      # Nothing left to iterate.
      return stop if @stack.empty?

      # Retrieve the next node.
      node = @stack.pop

      # If the node is a group, add its direct children to the queue
      # in reverse order so that the tree is traversed in pre-order.
      if node.is_a?(Indexable(Node))
        node.reverse_each { |child| @stack.push(child) }
      end

      # Return the current node.
      node
    end

    # Restart the iterator at the beginning.
    def rewind
      @stack.clear
      @stack.push(@group)
      self
    end
  end
end
