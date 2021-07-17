require "./example_group"
require "./example_group_hook"
require "./example_hook"
require "./example_procsy_hook"
require "./label"
require "./location"
require "./metadata"
require "./node_builder"

module Spectator
  # Progressively constructs an example group.
  # Hooks and builders for child nodes can be added over time to this builder.
  # When done, call `#build` to produce an `ExampleGroup`.
  class ExampleGroupBuilder < NodeBuilder
    @children = [] of NodeBuilder
    @before_all_hooks = [] of ExampleGroupHook
    @before_each_hooks = [] of ExampleHook
    @after_all_hooks = [] of ExampleGroupHook
    @after_each_hooks = [] of ExampleHook
    @around_each_hooks = [] of ExampleProcsyHook

    # Creates the builder.
    # Initially, the builder will have no children and no hooks.
    # The *name*, *location*, and *metadata* will be applied to the `ExampleGroup` produced by `#build`.
    def initialize(@name : Label = nil, @location : Location? = nil, @metadata : Metadata = Metadata.new)
    end

    # Attaches a hook to be invoked before any and all examples in the current group.
    def add_before_all_hook(hook)
      @before_all_hooks << hook
    end

    # Defines a block of code to execute before any and all examples in the current group.
    def before_all(&block)
      @before_all_hooks << ExampleGroupHook.new(&block)
    end

    # Attaches a hook to be invoked before every example in the current group.
    # The current example is provided as a block argument.
    def add_before_each_hook(hook)
      @before_each_hooks << hook
    end

    # Defines a block of code to execute before every example in the current group.
    # The current example is provided as a block argument.
    def before_each(&block : Example -> _)
      @before_each_hooks << ExampleHook.new(&block)
    end

    # Attaches a hook to be invoked after any and all examples in the current group.
    def add_after_all_hook(hook)
      @after_all_hooks << hook
    end

    # Defines a block of code to execute after any and all examples in the current group.
    def after_all(&block)
      @after_all_hooks << ExampleGroupHook.new(&block)
    end

    # Attaches a hook to be invoked after every example in the current group.
    # The current example is provided as a block argument.
    def add_after_each_hook(hook)
      @after_each_hooks << hook
    end

    # Defines a block of code to execute after every example in the current group.
    # The current example is provided as a block argument.
    def after_each(&block : Example -> _)
      @after_each_hooks << ExampleHook.new(&block)
    end

    # Attaches a hook to be invoked around every example in the current group.
    # The current example in procsy form is provided as a block argument.
    def add_around_each_hook(hook)
      @around_each_hooks << hook
    end

    # Defines a block of code to execute around every example in the current group.
    # The current example in procsy form is provided as a block argument.
    def around_each(&block : Example -> _)
      @around_each_hooks << ExampleProcsyHook.new(label: "around_each", &block)
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
      @before_all_hooks.each { |hook| group.add_before_all_hook(hook) }
      @before_each_hooks.each { |hook| group.add_before_each_hook(hook) }
      @after_all_hooks.each { |hook| group.add_after_all_hook(hook) }
      @after_each_hooks.each { |hook| group.add_after_each_hook(hook) }
      @around_each_hooks.each { |hook| group.add_around_each_hook(hook) }
    end
  end
end
