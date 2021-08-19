require "./example"
require "./node"

module Spectator
  # Iterates through all examples in a group and its nested groups.
  # Nodes are iterated in pre-order.
  class ExampleIterator
    include Iterator(Example)

    # A stack is used to track where in the tree this iterator is.
    @stack = Deque(Node).new(1)

    # Creates a new iterator.
    # The *group* is the example group to iterate through.
    def initialize(@group : Node)
      @stack.push(@group)
    end

    # Retrieves the next `Example`.
    # If there are none left, then `Iterator::Stop` is returned.
    def next
      # Keep going until either:
      # a. an example is found.
      # b. the stack is empty.
      until @stack.empty?
        # Retrieve the next node.
        # This could be an `Example` or a group.
        node = @stack.pop

        # If the node is a group, add its direct children to the queue
        # in reverse order so that the tree is traversed in pre-order.
        if node.is_a?(Indexable(Node))
          node.reverse_each { |child| @stack.push(child) }
        end

        # Return the node if it's an example.
        # Otherwise, advance and check the next one.
        return node if node.is_a?(Example)
      end

      # Nothing left to iterate.
      stop
    end

    # Restart the iterator at the beginning.
    def rewind
      @stack.clear
      @stack.push(@group)
      self
    end
  end
end
