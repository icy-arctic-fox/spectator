require "./events"
require "./example_procsy_hook"
require "./node"

module Spectator
  # Collection of examples and sub-groups.
  class ExampleGroup < Node
    include Enumerable(Node)
    include Events
    include Iterable(Node)

    @nodes = [] of Node

    # Parent group this group belongs to.
    getter! group : ExampleGroup

    # Assigns this group to the specified *group*.
    # This is an internal method and should only be called from `ExampleGroup`.
    # `ExampleGroup` manages the association of nodes to groups.
    protected setter group : ExampleGroup?

    # Calls all hooks from the parent group if there is a parent.
    # The *hook* is the method name of the group hook to invoke.
    private macro call_parent_hooks(hook)
      if (parent = @group)
        parent.{{hook.id}}
      end
    end

    # Calls all hooks from the parent group if there is a parent.
    # The *hook* is the method name of the example hook to invoke.
    # The current *example* must be provided.
    private macro call_parent_hooks(hook, example)
      if (parent = @group)
        parent.{{hook.id}}({{example}})
      end
    end

    # Calls group hooks of the current group.
    private def call_hooks(hooks)
      hooks.each do |hook|
        Log.trace { "Invoking hook #{hook}" }
        hook.call
      end
    end

    # Calls example hooks of the current group.
    # Requires the current *example*.
    private def call_hooks(hooks, example)
      hooks.each do |hook|
        Log.trace { "Invoking hook #{hook}" }
        hook.call(example)
      end
    end

    group_event before_all do |hooks|
      Log.trace { "Processing before_all hooks for #{self}" }

      call_parent_hooks(:call_once_before_all)
      call_hooks(hooks)
    end

    group_event after_all do |hooks|
      Log.trace { "Processing after_all hooks for #{self}" }

      call_hooks(hooks)
      call_parent_hooks(:call_once_after_all) if @group.try(&.finished?)
    end

    example_event before_each do |hooks, example|
      Log.trace { "Processing before_each hooks for #{self}" }

      call_parent_hooks(:call_before_each, example)
      call_hooks(hooks, example)
    end

    example_event after_each do |hooks, example|
      Log.trace { "Processing after_each hooks for #{self}" }

      call_hooks(hooks, example)
      call_parent_hooks(:call_after_each, example)
    end

    # Creates the example group.
    # The *name* describes the purpose of the group.
    # It can be a `Symbol` to describe a type.
    # The *location* tracks where the group exists in source code.
    # This group will be assigned to the parent *group* if it is provided.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    def initialize(@name : Label = nil, @location : Location? = nil,
                   @group : ExampleGroup? = nil, @metadata : Metadata = Metadata.new)
      # Ensure group is linked.
      group << self if group
    end

    # Removes the specified *node* from the group.
    # The node will be unassigned from this group.
    def delete(node : Node)
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

    # Constructs the full name or description of the example group.
    # This prepends names of groups this group is part of.
    def to_s(io)
      # Prefix with group's full name if the node belongs to a group.
      return unless parent = @group

      parent.to_s(io)
      name = @name

      # Add padding between the node names
      # only if the names don't appear to be symbolic.
      # Skip blank group names (like the root group).
      io << ' ' unless !parent.name? || # ameba:disable Style/NegatedConditionsInUnless
                       (parent.name?.is_a?(Symbol) && name.is_a?(String) &&
                       (name.starts_with?('#') || name.starts_with?('.')))

      super
    end

    # Adds the specified *node* to the group.
    # Assigns the node to this group.
    # If the node already belongs to a group,
    # it will be removed from the previous group before adding it to this group.
    def <<(node : Node)
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
    def around_each(&block) : Nil
      hook = ExampleProcsyHook.new(label: "around_each", &block)
      add_around_each_hook(hook)
    end

    # Signals that the *around_each* event has occurred.
    # All hooks associated with the event will be called.
    def call_around_each(example, &block : -> _) : Nil
      # Avoid overhead if there's no hooks.
      return yield if @around_hooks.empty?

      # Start with a procsy that wraps the original code.
      procsy = example.procsy(&block)
      procsy = wrap_around_each(procsy)
      procsy.call
    end

    # Wraps a procsy with the *around_each* hooks from this example group.
    # The returned procsy will call each hook then *procsy*.
    protected def wrap_around_each(procsy)
      # Avoid overhead if there's no hooks.
      return procsy if @around_hooks.empty?

      # Wrap each hook with the next.
      outer = procsy
      @around_hooks.reverse_each do |hook|
        outer = hook.wrap(outer)
      end

      # If there's a parent, wrap the procsy with its hooks.
      # Otherwise, return the outermost procsy.
      return outer unless (parent = group?)

      parent.wrap_around_each(outer)
    end
  end
end
