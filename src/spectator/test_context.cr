require "./example_hooks"
require "./test_values"

module Spectator
  class TestContext
    getter! parent

    getter values

    getter stubs : Hash(String, Deque(Mocks::MethodStub))

    def initialize(@parent : TestContext?,
                   @hooks : ExampleHooks,
                   @conditions : ExampleConditions,
                   @values : TestValues,
                   @stubs : Hash(String, Deque(Mocks::MethodStub)))
      @before_all_hooks_run = false
      @after_all_hooks_run = false
    end

    def run_before_hooks(example : Example)
      run_before_all_hooks
      run_before_each_hooks(example)
    end

    protected def run_before_all_hooks
      return if @before_all_hooks_run

      @parent.try &.run_before_all_hooks
      @hooks.run_before_all
    ensure
      @before_all_hooks_run = true
    end

    protected def run_before_each_hooks(example : Example)
      @parent.try &.run_before_each_hooks(example)
      @hooks.run_before_each(example.test_wrapper, example)
    end

    def run_after_hooks(example : Example)
      run_after_each_hooks(example)
      run_after_all_hooks(example.group)
    end

    protected def run_after_all_hooks(group : ExampleGroup, *, ignore_unfinished = false)
      return if @after_all_hooks_run
      return unless ignore_unfinished || group.finished?

      @hooks.run_after_all
      @parent.try do |parent_context|
        parent_group = group.as(NestedExampleGroup).parent
        parent_context.run_after_all_hooks(parent_group, ignore_unfinished: ignore_unfinished)
      end
    ensure
      @after_all_hooks_run = true
    end

    protected def run_after_each_hooks(example : Example)
      @hooks.run_after_each(example.test_wrapper, example)
      @parent.try &.run_after_each_hooks(example)
    end

    def wrap_around_each_hooks(test, &block : ->)
      wrapper = @hooks.wrap_around_each(test, block)
      if (parent = @parent)
        parent.wrap_around_each_hooks(test, &wrapper)
      else
        wrapper
      end
    end

    def run_pre_conditions(example)
      @parent.try &.run_pre_conditions(example)
      @conditions.run_pre_conditions(example.test_wrapper, example)
    end

    def run_post_conditions(example)
      @conditions.run_post_conditions(example.test_wrapper, example)
      @parent.try &.run_post_conditions(example)
    end
  end
end
