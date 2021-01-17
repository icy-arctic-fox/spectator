require "./events"
require "./spec_node"
require "./example_procsy_hook"

module Spectator
  # Collection of examples and sub-groups.
  class ExampleGroup < SpecNode
    include Enumerable(SpecNode)
    include Events
    include Iterable(SpecNode)

    @nodes = [] of SpecNode

    group_event before_all do |hooks|
      Log.trace { "Processing before_all hooks for #{self}" }

      if (parent = group?)
        parent.call_once_before_all
      end

      hooks.each do |hook|
        Log.trace { "Invoking hook #{hook}" }
        hook.call
      end
    end

    group_event after_all do |hooks|
      Log.trace { "Processing after_all hooks for #{self}" }

      hooks.each do |hook|
        Log.trace { "Invoking hook #{hook}" }
        hook.call
      end

      if (parent = group?)
        parent.call_once_after_all
      end
    end

    example_event before_each do |hooks, example|
      Log.trace { "Processing before_each hooks for #{self}" }

      if (parent = group?)
        parent.call_before_each(example)
      end

      hooks.each do |hook|
        Log.trace { "Invoking hook #{hook}" }
        hook.call(example)
      end
    end

    example_event after_each do |hooks, example|
      Log.trace { "Processing after_each hooks for #{self}" }

      hooks.each do |hook|
        Log.trace { "Invoking hook #{hook}" }
        hook.call(example)
      end

      if (parent = group?)
        parent.call_after_each(example)
      end
    end

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

    @around_hooks = [] of ExampleProcsyHook

    # Adds a hook to be invoked when the *around_each* event occurs.
    def add_around_each_hook(hook : ExampleProcsyHook) : Nil
      @around_hooks << hook
    end

    # Defines a hook for the *around_each* event.
    # The block of code given to this method is invoked when the event occurs.
    # The current example is provided as a block argument.
    def around_each(&block : Example::Procsy ->) : Nil
      hook = ExampleProcsyHook.new(label: "around_each", &block)
      add_around_each_hook(hook)
    end

    # Signals that the *around_each* event has occurred.
    # All hooks associated with the event will be called.
    def call_around_each(example : Example, &block : -> _) : Nil
      # Avoid overhead if there's no hooks.
      return yield if @around_hooks.empty?

      # Start with a procsy that wraps the original code.
      procsy = Example::Procsy.new(example, &block)
      procsy = wrap_around_each(procsy)
      procsy.call
    end

    # Wraps a procsy with the *around_each* hooks from this example group.
    # The returned procsy will call each hook then *procsy*.
    protected def wrap_around_each(procsy : Example::Procsy) : Example::Procsy
      # Avoid overhead if there's no hooks.
      return procsy if @around_hooks.empty?

      # Wrap each hook with the next.
      outer = procsy
      @around_hooks.each do |hook|
        outer = hook.wrap(outer)
      end

      # If there's a parent, wrap the procsy with its hooks.
      # Otherwise, return the outermost procsy.
      return outer unless (parent = group?)

      parent.wrap_around_each(outer)
    end
  end
end
