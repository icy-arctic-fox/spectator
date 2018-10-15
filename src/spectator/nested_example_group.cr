require "./example_group"

module Spectator
  class NestedExampleGroup < ExampleGroup
    getter what : String

    getter parent : ExampleGroup

    def initialize(@what, @parent, hooks : ExampleHooks)
      super(hooks)
    end

    def run_before_all_hooks : Nil
      parent.run_before_all_hooks
      super
    end

    def run_before_each_hooks : Nil
      parent.run_before_each_hooks
      super
    end

    def run_after_all_hooks : Nil
      super
      parent.run_after_all_hooks
    end

    def run_after_each_hooks : Nil
      super
      parent.run_after_each_hooks
    end

    def wrap_around_each_hooks(&block : ->) : ->
      wrapper = super(&block)
      parent.wrap_around_each_hooks(&wrapper)
    end

    def to_s(io)
      parent.to_s(io)
      io << ' '
      io << what
    end
  end
end
