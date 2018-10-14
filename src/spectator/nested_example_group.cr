require "./example_group"

module Spectator
  class NestedExampleGroup < ExampleGroup
    getter what : String

    getter! parent : ExampleGroup

    def initialize(@what, @parent, hooks : ExampleHooks)
      super(hooks)
    end

    def run_before_all_hooks : Nil
      if (parent = @parent)
        parent.run_before_all_hooks
      end
      super
    end

    def run_before_each_hooks : Nil
      if (parent = @parent)
        parent.run_before_each_hooks
      end
      super
    end

    def run_after_all_hooks : Nil
      super
      if (parent = @parent)
        parent.run_after_all_hooks
      end
    end

    def run_after_each_hooks : Nil
      super
      if (parent = @parent)
        parent.run_after_each_hooks
      end
    end

    def wrap_around_each_hooks(&block : ->) : ->
      super(&block).tap do |wrapper|
        if (parent = @parent)
          wrapper = parent.wrap_around_each_hooks(&wrapper)
        end
      end
    end

    def to_s(io)
      if (parent = @parent)
        parent.to_s(io)
        io << ' '
      end
      io << what
    end
  end
end
