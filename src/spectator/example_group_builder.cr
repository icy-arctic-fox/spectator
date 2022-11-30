require "./example_group"
require "./example_group_hook"
require "./example_hook"
require "./example_procsy_hook"
require "./hooks"
require "./label"
require "./location"
require "./metadata"
require "./node_builder"

module Spectator
  # Progressively constructs an example group.
  # Hooks and builders for child nodes can be added over time to this builder.
  # When done, call `#build` to produce an `ExampleGroup`.
  class ExampleGroupBuilder < NodeBuilder
    include Hooks

    define_hook before_all : ExampleGroupHook
    define_hook after_all : ExampleGroupHook, :prepend
    define_hook before_each : ExampleHook
    define_hook after_each : ExampleHook, :prepend
    define_hook pre_condition : ExampleHook
    define_hook post_condition : ExampleHook, :prepend
    define_hook around_each : ExampleProcsyHook

    @children = [] of NodeBuilder

    # Creates the builder.
    # Initially, the builder will have no children and no hooks.
    # The *name*, *location*, and *metadata* will be applied to the `ExampleGroup` produced by `#build`.
    def initialize(@name : Label = nil, @location : Location? = nil, @metadata : Metadata? = nil)
    end

    # Constructs an example group with previously defined attributes, children, and hooks.
    # The *parent* is an already constructed example group to nest the new example group under.
    # It can be nil if the new example group won't have a parent.
    def build(parent = nil)
      ExampleGroup.new(@name, @location, parent, @metadata).tap do |group|
        apply_hooks(group)
        @children.each(&.build(group))
      end
    end

    # Adds a child builder to the group.
    # The *builder* will have `NodeBuilder#build` called on it from within `#build`.
    # The new example group will be passed to it.
    def <<(builder)
      @children << builder
    end

    # Adds all previously configured hooks to an example group.
    private def apply_hooks(group)
      before_all_hooks.each { |hook| group.before_all(hook) }
      before_each_hooks.each { |hook| group.before_each(hook) }
      after_all_hooks.reverse_each { |hook| group.after_all(hook) }
      after_each_hooks.reverse_each { |hook| group.after_each(hook) }
      around_each_hooks.each { |hook| group.around_each(hook) }
      pre_condition_hooks.each { |hook| group.pre_condition(hook) }
      post_condition_hooks.reverse_each { |hook| group.post_condition(hook) }
    end
  end
end
