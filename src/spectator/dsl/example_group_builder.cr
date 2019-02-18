module Spectator::DSL
  # Base class for building all example groups.
  abstract class ExampleGroupBuilder
    # Type alias for valid children of example groups.
    # NOTE: `NestedExampleGroupBuilder` is used instead of `ExampleGroupBuilder`.
    # That is because `RootExampleGroupBuilder` also inherits from this class,
    # and the root example group can't be a child.
    alias Child = ExampleFactory | NestedExampleGroupBuilder

    # Factories and builders for all examples and groups.
    @children = [] of Child

    # Hooks added to the group so far.
    @before_all_hooks = [] of ->
    @before_each_hooks = [] of ->
    @after_all_hooks = [] of ->
    @after_each_hooks = [] of ->
    @around_each_hooks = [] of Proc(Nil) ->

    # Pre and post conditions so far.
    @pre_conditions = [] of ->
    @post_conditions = [] of ->

    # Adds a new example factory or group builder to this group.
    def add_child(child : Child)
      @children << child
    end

    # Adds a hook to run before all examples (and nested examples) in this group.
    def add_before_all_hook(block : ->) : Nil
      @before_all_hooks << block
    end

    # Adds a hook to run before each example (and nested example) in this group.
    def add_before_each_hook(block : ->) : Nil
      @before_each_hooks << block
    end

    # Adds a hook to run after all examples (and nested examples) in this group.
    def add_after_all_hook(block : ->) : Nil
      @after_all_hooks << block
    end

    # Adds a hook to run after each example (and nested example) in this group.
    def add_after_each_hook(block : ->) : Nil
      @after_each_hooks << block
    end

    # Adds a hook to run around each example (and nested example) in this group.
    # The block of code will be given another proc as an argument.
    # It is expected that the block will call the proc.
    def add_around_each_hook(block : Proc(Nil) ->) : Nil
      @around_each_hooks << block
    end

    # Adds a pre-condition to run at the start of every example in this group.
    def add_pre_condition(block : ->) : Nil
      @pre_conditions << block
    end

    # Adds a post-condition to run at the end of every example in this group.
    def add_post_condition(block : ->) : Nil
      @post_conditions << block
    end

    # Constructs an `ExampleHooks` instance with all the hooks defined for this group.
    # This method should be called only when the group is being built,
    # otherwise some hooks may be missing.
    private def hooks
      ExampleHooks.new(
        @before_all_hooks,
        @before_each_hooks,
        @after_all_hooks,
        @after_each_hooks,
        @around_each_hooks
      )
    end

    # Constructs an `ExampleConditions` instance
    # with all the pre- and post-conditions defined for this group.
    # This method should be called only when the group is being built,
    # otherwise some conditions may be missing.
    private def conditions
      ExampleConditions.new(@pre_conditions, @post_conditions)
    end
  end
end
