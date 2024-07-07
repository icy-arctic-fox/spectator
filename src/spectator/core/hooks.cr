require "./context_hook"
require "./example_hook"

module Spectator::Core
  module Hooks
    private macro create_example_hook(position)
    end

    private macro create_context_hook(position)
      location = LocationRange.new(source_file, source_line, source_end_line)
      ContextHook.new({{position}}, location, &block)
    end

    def before_each(*,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__,
                    &block : Example ->) : ExampleHook(Example)
      hooks = @before_each ||= [] of ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:before, location, &block)
      hooks << hook
      hook
    end

    @before_each_priority_hooks = 0

    private def before_each!(*,
                             source_file = __FILE__,
                             source_line = __LINE__,
                             source_end_line = __END_LINE__,
                             &block : Example ->) : ExampleHook(Example)
      hooks = @before_each ||= [] of ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:before, location, &block)
      hooks.insert(@before_each_priority_hooks, hook)
      @before_each_priority_hooks += 1
      hook
    end

    def before(*,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__,
               &block : Example ->) : ExampleHook(Example)
      before_each(source_file: source_file, source_line: source_line, source_end_line: source_end_line, &block)
    end

    def after_each(*,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__,
                   &block : Example ->) : ExampleHook(Example)
      hooks = @after_each ||= [] of ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:after, location, &block)
      hooks << hook
      hook
    end

    def after(*,
              source_file = __FILE__,
              source_line = __LINE__,
              source_end_line = __END_LINE__,
              &block : Example ->) : ExampleHook(Example)
      after_each(source_file: source_file, source_line: source_line, source_end_line: source_end_line, &block)
    end

    @after_each_priority_hooks = 0

    private def after_each!(*,
                            source_file = __FILE__,
                            source_line = __LINE__,
                            source_end_line = __END_LINE__,
                            &block : Example ->) : ExampleHook(Example)
      hooks = @after_each ||= [] of ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:after, location, &block)
      hooks.insert(@after_each_priority_hooks, hook)
      @after_each_priority_hooks += 1
      hook
    end

    def before_all(*,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__,
                   &block : ->) : ContextHook
      hooks = @before_all ||= [] of ContextHook
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ContextHook.new(:before, location, &block)
      hooks << hook
      hook
    end

    def after_all(*,
                  source_file = __FILE__,
                  source_line = __LINE__,
                  source_end_line = __END_LINE__,
                  &block : ->) : ContextHook
      hooks = @after_all ||= [] of ContextHook
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ContextHook.new(:after, location, &block)
      hooks << hook
      hook
    end

    def around_each(*,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__,
                    & : Example::Procsy ->) : ExampleHook(Example::Procsy)
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
