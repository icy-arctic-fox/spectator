require "./example_group"

module Spectator
  # A collection of examples and other example groups.
  # This group can be nested under other groups.
  class NestedExampleGroup < ExampleGroup
    # Description from the user of the group's contents.
    # This is a symbol when referencing a type.
    getter what : Symbol | String

    # Group that this is nested in.
    getter parent : ExampleGroup

    # Creates a new example group.
    # The *what* argument is a description from the user.
    # The *parent* should contain this group.
    # After creating this group, the parent's children should be updated.
    # The parent's children must contain this group,
    # otherwise there may be unexpected behavior.
    # The *hooks* are stored to be triggered later.
    def initialize(@what, @parent, hooks : ExampleHooks, conditions : ExampleConditions)
      super(hooks, conditions)
    end

    # Indicates wheter the group references a type.
    def symbolic? : Bool
      @what.is_a?(Symbol)
    end

    # Runs all of the "before-all" hooks.
    # This should run prior to any examples in the group.
    # The hooks will be run only once.
    # Subsequent calls to this method will do nothing.
    # Parent "before-all" hooks will be run first.
    protected def run_before_all_hooks : Nil
      parent.run_before_all_hooks
      super
    end

    # Runs all of the "before-each" hooks.
    # This method should run prior to every example in the group.
    # Parent "before-each" hooks will be run first.
    protected def run_before_each_hooks : Nil
      parent.run_before_each_hooks
      super
    end

    # Runs all of the "after-all" hooks.
    # This should run following all examples in the group.
    # The hooks will be run only once,
    # and only after all examples in the group have finished.
    # Subsequent calls after the hooks have been run will do nothing.
    # Parent "after-all" hooks will be run last.
    protected def run_after_all_hooks(ignore_unfinished = false) : Nil
      super
      parent.run_after_all_hooks(ignore_unfinished)
    end

    # Runs all of the "after-each" hooks.
    # This method should run following every example in the group.
    # Parent "after-each" hooks will be run last.
    protected def run_after_each_hooks : Nil
      super
      parent.run_after_each_hooks
    end

    # Creates a proc that runs the "around-each" hooks
    # in addition to a block passed to this method.
    # To call the block and all `around_each` hooks,
    # just invoke `Proc#call` on the returned proc.
    # Parent "around-each" hooks will be in the outermost wrappings.
    def wrap_around_each_hooks(&block : ->) : ->
      wrapper = super(&block)
      parent.wrap_around_each_hooks(&wrapper)
    end

    # Runs all of the pre-condition checks.
    # This method should run prior to every example in the group.
    # Parent pre-conditions will be checked first.
    def run_pre_conditions : Nil
      parent.run_pre_conditions
      super
    end

    # Runs all of the post-condition checks.
    # This method should run following every example in the group.
    # Parent post-conditions will be checked last.
    def run_post_conditions : Nil
      super
      parent.run_post_conditions
    end

    # Creates a string representation of the group.
    # The string consists of `#what` appended to the parent.
    # This results in a string like:
    # ```text
    # Foo#bar does something
    # ```
    # for the following structure:
    # ```
    # describe Foo do
    #   describe "#bar" do
    #     it "does something" do
    #       # ...
    #     end
    #   end
    # end
    # ```
    def to_s(io)
      parent.to_s(io)
      io << ' ' unless (symbolic? || parent.is_a?(RootExampleGroup)) && parent.symbolic?
      io << what
    end
  end
end
