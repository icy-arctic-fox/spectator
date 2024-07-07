require "./context_hook"
require "./example_hook"

module Spectator::Core
  module Hooks
    def before_each(*, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : Example ->) : ExampleHook(Example)
      location = LocationRange.new(file, line, end_line)
      hook = ExampleHook(Example).new(:before, location, &block)
      hooks = @before_each ||= [] of ExampleHook(Example)
      hooks << hook
      hook
    end

    private getter critical_before_each_hooks = 0

    private def before_each!(&block : Example ->) : Nil
      hook = ExampleHook(Example).new(:before, &block)
      hooks = @before_each ||= [] of ExampleHook(Example)
      hooks.insert(@critical_before_each_hooks, hook)
      @critical_before_each_hooks += 1
    end

    def before(*, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : Example ->) : ExampleHook(Example)
      before_each(file: file, line: line, end_line: end_line, &block)
    end

    def after_each(*, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : Example ->) : ExampleHook(Example)
      location = LocationRange.new(file, line, end_line)
      hook = ExampleHook(Example).new(:after, location, &block)
      hooks = @after_each ||= [] of ExampleHook(Example)
      hooks << hook
      hook
    end

    def after(*, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : Example ->) : ExampleHook(Example)
      after_each(file: file, line: line, end_line: end_line, &block)
    end

    private getter critical_after_each_hooks = 0

    private def after_each!(&block : Example ->) : Nil
      hook = ExampleHook(Example).new(:after, &block)
      hooks = @after_each ||= [] of ExampleHook(Example)
      hooks.insert(@critical_after_each_hooks, hook)
      @critical_after_each_hooks += 1
    end

    def before_all(*, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : ->) : ContextHook
      location = LocationRange.new(file, line, end_line)
      hook = ContextHook.new(:before, location, &block)
      hooks = @before_all ||= [] of ContextHook
      hooks << hook
      hook
    end

    def after_all(*, file = __FILE__, line = __LINE__, end_line = __END_LINE__, &block : ->) : ContextHook
      location = LocationRange.new(file, line, end_line)
      hook = ContextHook.new(:after, location, &block)
      hooks = @after_all ||= [] of ContextHook
      hooks << hook
      hook
    end

    def around_each(*, file = __FILE__, line = __LINE__, end_line = __END_LINE__, & : Example::Procsy ->) : ExampleHook(Example::Procsy)
      location = LocationRange.new(file, line, end_line)
      hook = ExampleHook(Example::Procsy).new(:around, location, &block)
      hooks = @around_each ||= [] of ExampleHook(Example::Procsy)
      hooks << hook
      hook
    end

    # TODO: around_all

    def with_hooks(example : Example, &block : ->) : Nil
      if context = parent?
        context.with_hooks(example) do
          with_current_context_hooks(example, &block)
        end
      else
        with_current_context_hooks(example, &block)
      end
    end

    private def with_current_context_hooks(example : Example, &block : ->) : Nil
      @before_all.try &.each &.call
      @before_each.try &.each &.call(example)
      # TODO: around_each
      block.call
      @after_each.try &.each &.call(example)
      @after_all.try &.each &.call
    end
  end
end
