require "./node_builder"

module Spectator
  class ExampleGroupBuilder < NodeBuilder
    @children = [] of NodeBuilder
    @before_all_hooks = [] of ExampleGroupHook
    @before_each_hooks = [] of ExampleHook
    @after_all_hooks = [] of ExampleGroupHook
    @after_each_hooks = [] of ExampleHook
    @around_each_hooks = [] of ExampleProcsyHook

    def initialize(@name : Label = nil, @location : Location? = nil, @metadata : Metadata = Metadata.new)
    end

    # Attaches a hook to be invoked before any and all examples in the current group.
    def add_before_all_hook(hook)
      @before_all_hooks << hook
    end

    # Defines a block of code to execute before any and all examples in the current group.
    def add_before_all_hook(&block)
      @before_all_hooks << ExampleGroupHook.new(&block)
    end

    # Attaches a hook to be invoked before every example in the current group.
    # The current example is provided as a block argument.
    def add_before_each_hook(hook)
      @before_each_hooks << hook
    end

    # Defines a block of code to execute before every example in the current group.
    # The current example is provided as a block argument.
    def add_before_each_hook(&block : Example -> _)
      @before_each_hooks << ExampleHook.new(&block)
    end

    # Attaches a hook to be invoked after any and all examples in the current group.
    def add_after_all_hook(hook)
      @after_all_hooks << hook
    end

    # Defines a block of code to execute after any and all examples in the current group.
    def add_after_all_hook(&block)
      @after_all_hooks << ExampleGroupHook.new(&block)
    end

    # Attaches a hook to be invoked after every example in the current group.
    # The current example is provided as a block argument.
    def add_after_each_hook(hook)
      @after_each_hooks << hook
    end

    # Defines a block of code to execute after every example in the current group.
    # The current example is provided as a block argument.
    def add_after_each_hook(&block : Example -> _)
      @after_each_hooks << ExampleHook.new(&block)
    end

    # Attaches a hook to be invoked around every example in the current group.
    # The current example in procsy form is provided as a block argument.
    def add_around_each_hook(hook)
      @around_each_hooks << hook
    end

    # Defines a block of code to execute around every example in the current group.
    # The current example in procsy form is provided as a block argument.
    def add_around_each_hook(&block : Example -> _)
      @around_each_hooks << ExampleProcsyHook.new(label: "around_each", &block)
    end

    def build(parent = nil)
      ExampleGroup.new(@name, @location, parent, @metadata).tap do |group|
        @before_all_hooks.each { |hook| group.add_before_all_hook(hook) }
        @before_each_hooks.each { |hook| group.add_before_each_hook(hook) }
        @after_all_hooks.each { |hook| group.add_after_all_hook(hook) }
        @after_each_hooks.each { |hook| group.add_after_each_hook(hook) }
        @around_each_hooks.each { |hook| group.add_around_each_hook(hook) }
        @children.each(&.build(group))
      end
    end

    def <<(builder)
      @children << builder
    end
  end
end
