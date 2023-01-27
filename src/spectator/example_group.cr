require "./example_procsy_hook"
require "./hooks"
require "./node"

module Spectator
  # Collection of examples and sub-groups.
  class ExampleGroup < Node
    include Hooks
    include Indexable(Node)

    @nodes = [] of Node

    # Parent group this group belongs to.
    getter! group : ExampleGroup

    # Assigns this group to the specified *group*.
    # This is an internal method and should only be called from `ExampleGroup`.
    # `ExampleGroup` manages the association of nodes to groups.
    protected setter group : ExampleGroup?

    define_hook before_all : ExampleGroupHook do
      Log.trace { "Processing before_all hooks for: #{self}" }

      @group.try &.call_before_all
      before_all_hooks.each &.call_once
    end

    define_hook after_all : ExampleGroupHook, :prepend do
      Log.trace { "Processing after_all hooks for: #{self}" }

      after_all_hooks.each &.call_once if finished?
      if group = @group
        group.call_after_all if group.finished?
      end
    end

    define_hook before_each : ExampleHook do |example|
      Log.trace { "Processing before_each hooks for: #{self}" }

      @group.try &.call_before_each(example)
      before_each_hooks.each &.call(example)
    end

    define_hook after_each : ExampleHook, :prepend do |example|
      Log.trace { "Processing after_each hooks for: #{self}" }

      after_each_hooks.each &.call(example)
      @group.try &.call_after_each(example)
    end

    define_hook around_each : ExampleProcsyHook do |procsy|
      Log.trace { "Processing around_each hooks for: #{self}" }

      around_each_hooks.reverse_each { |hook| procsy = hook.wrap(procsy) }
      if group = @group
        procsy = group.call_around_each(procsy)
      end
      procsy
    end

    define_hook pre_condition : ExampleHook do |example|
      Log.trace { "Processing pre_condition hooks for: #{self}" }

      @group.try &.call_pre_condition(example)
      pre_condition_hooks.each &.call(example)
    end

    define_hook post_condition : ExampleHook, :prepend do |example|
      Log.trace { "Processing post_condition hooks for: #{self}" }

      post_condition_hooks.each &.call(example)
      @group.try &.call_post_condition(example)
    end

    # Creates the example group.
    # The *name* describes the purpose of the group.
    # It can be a `Symbol` to describe a type.
    # The *location* tracks where the group exists in source code.
    # This group will be assigned to the parent *group* if it is provided.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    def initialize(@name : Label = nil, @location : Location? = nil,
                   @group : ExampleGroup? = nil, @metadata : Metadata? = nil)
      # Ensure group is linked.
      group << self if group
    end

    delegate size, unsafe_fetch, to: @nodes

    # Yields this group and all parent groups.
    def ascend(&)
      group = self
      while group
        yield group
        group = group.group?
      end
    end

    # Removes the specified *node* from the group.
    # The node will be unassigned from this group.
    def delete(node : Node)
      # Only remove from the group if it is associated with this group.
      return unless node.group == self

      node.group = nil
      @nodes.delete(node)
    end

    # Checks if all examples and sub-groups have finished.
    def finished? : Bool
      @nodes.all?(&.finished?)
    end

    # Constructs the full name or description of the example group.
    # This prepends names of groups this group is part of.
    def to_s(io : IO, *, nested = false) : Nil
      unless parent = @group
        # Display special string when called directly.
        io << "<root>" unless nested
        return
      end

      # Prefix with group's full name if the node belongs to a group.
      parent.to_s(io, nested: true)
      name = @name

      # Add padding between the node names
      # only if the names don't appear to be symbolic.
      # Skip blank group names (like the root group).
      io << ' ' unless !parent.name? || # ameba:disable Style/NegatedConditionsInUnless
                       (parent.name?.is_a?(Symbol) && name.is_a?(String) &&
                       (name.starts_with?('#') || name.starts_with?('.')))

      super(io)
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
  end
end
