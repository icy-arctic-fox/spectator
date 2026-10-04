require "./context"
require "./context_hook"
require "./example_hook"

module Spectator::Core
  module Hooks
    getter before_each_hooks do
      [] of ExampleHook(Example)
    end

    getter after_each_hooks do
      [] of ExampleHook(Example)
    end

    getter before_all_hooks do
      [] of ContextHook
    end

    getter after_all_hooks do
      [] of ContextHook
    end

    getter around_each_hooks do
      [] of ExampleHook(Example::Procsy)
    end

    def with_hooks(example : Example, &block : Example::Procsy ->)
      if context = parent
        context.with_hooks(example) do
          with_current_context_hooks(example, &block)
        end
      else
        with_current_context_hooks(example, &block)
      end
    end

    private def with_current_context_hooks(example : Example, &block : Example::Procsy ->)
      proc = example.to_proc do |procsy|
        @before_each_hooks.try &.each &.call(example)
        block.call(procsy)
        @after_each_hooks.try &.each &.call(example)
      end
      @around_each_hooks.try &.reverse_each do |hook|
        proc = proc.wrap(&->hook.call(Example::Procsy))
      end

      @before_all_hooks.try &.each &.call
      proc.run

      # Only run after_all hooks if this is the last example to run in its group.
      @after_all_hooks.try &.each &.call if run?
    end
  end

  module HooksDSL
    def before_each(*,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__,
                    &block : Example ->) : ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:before, location, &block)
      context.before_each_hooks << hook
      hook
    end

    def before(*,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__,
               &block : Example ->) : ExampleHook(Example)
      before_each(source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line,
        &block)
    end

    def after_each(*,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__,
                   &block : Example ->) : ExampleHook(Example)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example).new(:after, location, &block)
      context.after_each_hooks << hook
      hook
    end

    def after(*,
              source_file = __FILE__,
              source_line = __LINE__,
              source_end_line = __END_LINE__,
              &block : Example ->) : ExampleHook(Example)
      after_each(source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line,
        &block)
    end

    def before_all(*,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__,
                   &block : ->) : ContextHook
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ContextHook.new(:before, location, &block)
      context.before_all_hooks << hook
      hook
    end

    def after_all(*,
                  source_file = __FILE__,
                  source_line = __LINE__,
                  source_end_line = __END_LINE__,
                  &block : ->) : ContextHook
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ContextHook.new(:after, location, &block)
      context.after_all_hooks << hook
      hook
    end

    def before_suite(*,
                     source_file = __FILE__,
                     source_line = __LINE__,
                     source_end_line = __END_LINE__,
                     &block : ->) : ContextHook
      Spectator.root_example_group.before_all(
        source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line,
        &block)
    end

    def after_suite(*,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__,
                    &block : ->) : ContextHook
      Spectator.root_example_group.after_all(
        source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line,
        &block)
    end

    def around_each(*,
                    source_file = __FILE__,
                    source_line = __LINE__,
                    source_end_line = __END_LINE__,
                    &block : Example::Procsy ->) : ExampleHook(Example::Procsy)
      location = LocationRange.new(source_file, source_line, source_end_line)
      hook = ExampleHook(Example::Procsy).new(:around, location, &block)
      context.around_each_hooks << hook
      hook
    end

    def around(*,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__,
               &block : Example::Procsy ->) : ExampleHook(Example::Procsy)
      around_each(
        source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line,
        &block)
    end

    # TODO: around_all
  end

  module Context
    include Hooks
  end

  struct ContextDSL
    include HooksDSL
  end

  class Configuration
    include HooksDSL
  end
end
