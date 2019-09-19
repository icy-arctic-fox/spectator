require "../test_context"
require "./example_builder"

module Spectator::SpecBuilder
  abstract class ExampleGroupBuilder
    alias Child = NestedExampleGroupBuilder | ExampleBuilder

    private getter children = Deque(Child).new

    @before_each_hooks = Deque(TestMethod).new
    @after_each_hooks = Deque(TestMethod).new
    @before_all_hooks = Deque(->).new
    @after_all_hooks = Deque(->).new
    @around_each_hooks = Deque(::SpectatorTest, Proc(Nil) ->).new

    def add_child(child : Child)
      @children << child
    end

    def add_before_each_hook(hook : TestMethod)
      @before_each_hooks << hook
    end

    def add_after_each_hook(hook : TestMethod)
      @after_each_hooks << hook
    end

    def add_before_all_hook(hook : ->)
      @before_all_hooks << hook
    end

    def add_after_all_hook(hook : ->)
      @after_all_hooks << hook
    end

    def add_around_each_hook(hook : ::SpectatorTest, Proc(Nil) ->)
      @around_each_hooks << hook
    end

    private def build_hooks
      ExampleHooks.new(
        @before_all_hooks.to_a,
        @before_each_hooks.to_a,
        @after_all_hooks.to_a,
        @after_each_hooks.to_a,
        @around_each_hooks.to_a
      )
    end
  end
end
