require "./example_component"

module Spectator
  # Shared base class for groups of examples.
  #
  # Represents a collection of examples and other groups.
  # Use the `#each` methods to iterate through each child.
  # However, these methods do not recurse into sub-groups.
  # If you need that functionality, see `ExampleIterator`.
  # Additionally, the indexer method (`#[]`) will index into sub-groups.
  #
  # This class also stores hooks to be associated with all examples in the group.
  # The hooks can be invoked by running one of the `#run_x_hooks` methods.
  abstract class ExampleGroup < ExampleComponent
    include Enumerable(ExampleComponent)
    include Iterable(ExampleComponent)

    # Creates the example group.
    # The hooks are stored to be triggered later.
    def initialize(@hooks : ExampleHooks)
      @before_all_hooks_run = false
      @after_all_hooks_run = false
    end

    # Retrieves the children in the group.
    # This only returns the direct descends (non-recursive).
    # The children must be set (with `#children=`) prior to calling this method.
    getter! children : Array(ExampleComponent)

    # Sets the children of the group.
    # This should be called only from a builder in the `DSL` namespace.
    # The children can be set only once -
    # attempting to set more than once will raise an error.
    # All sub-groups' children should be set before setting this group's children.
    def children=(children : Array(ExampleComponent))
      raise "Attempted to reset example group children" if @children
      @children = children
      # Recursively count the number of examples.
      # This won't work if a sub-group hasn't had their children set (is still nil).
      @example_count = children.sum(&.example_count)
    end

    # Yields each direct descendant.
    def each
      children.each do |child|
        yield child
      end
    end

    # Returns an iterator for each direct descendant.
    def each : Iterator(ExampleComponent)
      children.each
    end

    # Number of examples in this group and all sub-groups.
    getter example_count = 0

    # Retrieves an example by its index.
    # This recursively searches for an example.
    #
    # Positive and negative indices can be used.
    # Any value out of range will raise an `IndexError`.
    #
    # Examples are indexed as if they are in a flattened tree.
    # For instance:
    # ```
    # examples = [0, 1, [2, 3, 4], [5, [6, 7], 8], 9, [10]].flatten
    # ```
    # The arrays symbolize groups,
    # and the numbers are the index of the example in that slot.
    def [](index : Int) : Example
      offset = check_bounds(index)
      find_nested(offset)
    end

    # Checks whether an index is within acceptable bounds.
    # If the index is negative,
    # it will be converted to its positive equivalent.
    # If the index is out of bounds, an `IndexError` is raised.
    # If the index is in bounds,
    # the positive index is returned.
    private def check_bounds(index)
      if index < 0
        raise IndexError.new if index < -example_count
        index + example_count
      else
        raise IndexError.new if index >= example_count
        index
      end
    end

    # Finds the example with the specified index in the children.
    # The `index` must be positive and within bounds (use `#check_bounds`).
    private def find_nested(index)
      offset = index
      # Loop through each child
      # until one is found to contain the index.
      child = children.each do |child|
        count = child.example_count
        # Example groups consider their range to be [0, example_count).
        # Each child is offset by the total example count of the previous children.
        # The group exposes them in this way:
        # 1. [0, example_count of group 1)
        # 2. [example_count of group 1, example_count of group 2)
        # 3. [example_count of group n, example_count of group n + 1)
        # To iterate through children, the offset is tracked.
        # Each iteration removes the previous child's count.
        # This way the child receives the expected range.
        break child if offset < count
        offset -= count
      end
      # The remaining offset is passed along to the child.
      # If it's an `Example`, it returns itself.
      # Otherwise, the indexer repeats the process for the next child.
      # It should be impossible to get `nil` here,
      # provided the bounds check and example counts are correct.
      child.not_nil![offset]
    end

    # Checks whether all examples in the group have been run.
    def finished? : Bool
      children.all?(&.finished?)
    end

    # Runs all of the `before_all` and `before_each` hooks.
    # This should run prior to every example in the group.
    # The `example` argument should be the example about to be run.
    def run_before_hooks(example : Example)
      run_before_all_hooks
      run_before_each_hooks(example)
    end

    # Runs all of the `before_all` hooks.
    # This should run prior to any examples in the group.
    # The hooks will be run only once.
    # Subsequent calls to this method will do nothing.
    protected def run_before_all_hooks : Nil
      return if @before_all_hooks_run
      @hooks.run_before_all
      @before_all_hooks_run = true
    end

    # Runs all of the `before_each` hooks.
    # This method should run prior to every example in the group.
    # The `example` argument should be the example about to be run.
    protected def run_before_each_hooks(example) : Nil
      @hooks.run_before_each(example)
    end

    # Runs all of the `after_all` and `after_each` hooks.
    # This should run following every example in the group.
    # The `example` argument should be the example that just ran.
    def run_after_hooks(example : Example)
      run_after_each_hooks(example)
      run_after_all_hooks
    end

    # Runs all of the `after_all` hooks.
    # This should run following all examples in the group.
    # The hooks will be run only once,
    # and only after all examples in the group have finished.
    # Subsequent calls after the hooks have been run will do nothing.
    protected def run_after_all_hooks : Nil
      return if @after_all_hooks_run
      return unless finished?
      @hooks.run_after_all
      @after_all_hooks_run = true
    end

    # Runs all of the `after_each` hooks.
    # This method should run following every example in the group.
    # The `example` argument should be the example that just ran.
    protected def run_after_each_hooks(example) : Nil
      @hooks.run_after_each(example)
    end

    # Creates a proc that runs the `around_each` hooks
    # in addition to a block passed to this method.
    # To call the block and all `around_each` hooks,
    # just invoke `Proc#call` on the returned proc.
    def wrap_around_each_hooks(&block : ->) : ->
      @hooks.wrap_around_each(&block)
    end
  end
end
