require "./context_hook"
require "./example_hook"

module Spectator::Core
  module Hooks
    protected getter before_each_hooks do
      [] of ExampleHook(Example)
    end

    def before_each(*,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__,
                    &block : Example ->) : ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:before, location, &block)
      before_each_hooks << hook
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

    protected getter after_each_hooks do
      [] of ExampleHook(Example)
    end

    def after_each(*,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__,
                   &block : Example ->) : ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:after, location, &block)
      after_each_hooks << hook
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

    protected getter before_all_hooks do
      [] of ContextHook
    end

    def before_all(*,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__,
                   &block : ->) : ContextHook
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ContextHook.new(:before, location, &block)
      before_all_hooks << hook
      hook
    end

    protected getter after_all_hooks do
      [] of ContextHook
    end

    def after_all(*,
                  source_file = __FILE__,
                  source_line = __LINE__,
                  source_end_line = __END_LINE__,
                  &block : ->) : ContextHook
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ContextHook.new(:after, location, &block)
      after_all_hooks << hook
      hook
    end

    protected getter around_each_hooks do
      [] of ExampleHook(Example::Procsy)
    end

    def around_each(*,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__,
                    & : Example::Procsy ->) : ExampleHook(Example::Procsy)
      location = LocationRange.new(file, line, end_line)
      hook = ExampleHook(Example::Procsy).new(:around, location, &block)
      around_each_hooks << hook
      hook
    end

    # TODO: before_suite and after_suite

    # TODO: around_all

    protected def with_hooks(example : Example, &block : ->) : Nil
      if context = parent?
        context.with_hooks(example) do
          with_current_context_hooks(example, &block)
        end
      else
        with_current_context_hooks(example, &block)
      end
    end

    private def with_current_context_hooks(example : Example, &block : ->) : Nil
      @before_all_hooks.try &.each &.call
      @before_each_hooks.try &.each &.call(example)
      # TODO: around_each
      block.call
      @after_each_hooks.try &.each &.call(example)
      @after_all_hooks.try &.each &.call
    end
  end
end