module Spectator
  # Iterates through all examples in a group and its nested groups.
  class ExampleIterator
    include Iterator(Example)

    # Stack that contains the iterators for each group.
    # A stack is used to track where in the tree this iterator is.
    @stack : Array(Iterator(ExampleComponent))

    # Creates a new iterator.
    # The *group* is the example group to iterate through.
    def initialize(@group : Iterable(ExampleComponent))
      iter = @group.each.as(Iterator(ExampleComponent))
      @stack = [iter]
    end

    # Retrieves the next `Example`.
    # If there are none left, then `Iterator::Stop` is returned.
    def next
      # Keep going until either:
      # a. an example is found.
      # b. the stack is empty.
      until @stack.empty?
        # Retrieve the next "thing".
        # This could be an `Example`,
        # or a group.
        item = advance
        # Return the item if it's an example.
        # Otherwise, advance and check the next one.
        return item if item.is_a?(Example)
      end
      # Nothing left to iterate.
      stop
    end

    # Restart the iterator at the beginning.
    def rewind
      # Same code as `#initialize`, but return self.
      iter = @group.each.as(Iterator(ExampleComponent))
      @stack = [iter]
      self
    end

    # Retrieves the top of the stack.
    private def top
      @stack.last
    end

    # Retrieves the next "thing" from the tree.
    # This method will return an `Example` or "something else."
    private def advance
      # Get the iterator from the top of the stack.
      # Advance the iterator and check what the next item is.
      case (item = top.next)
      when ExampleGroup
        # If the next thing is a group,
        # we need to traverse its branch.
        # Push its iterator onto the stack and return.
        @stack.push(item.each)
      when Iterator::Stop
        # If a stop instance is encountered,
        # then the current group is done.
        # Pop its iterator from the stack and return.
        @stack.pop
      else
        # Found an example, return it.
        item
      end
    end
  end
end
