require "./example_hook"

module Spectator::Core
  module Hooks
    def before_each(&block : Example ->) : Nil
      hooks = @before_each ||= [] of ExampleHook(Example)
      hooks << ExampleHook(Example).new(&block)
    end

    def after_each(&block : Example ->)
      hooks = @after_each ||= [] of ExampleHook(Example)
      hooks << ExampleHook(Example).new(&block)
    end

    def before_all(&block : ->)
      hooks = @before_all ||= [] of ContextHook
      hooks << ContextHook.new(&block)
    end

    def after_all(&block : ->)
      hooks = @after_all ||= [] of ContextHook
      hooks << ContextHook.new(&block)
    end

    def around_each(& : Example ->)
      hooks = @around_each ||= [] of ExampleHook(Example::Procsy)
      hooks << ExampleHook(Example::Procsy).new(&block)
    end

    def around_all(& : ->)
    end

    def with_hooks(example : Example, &block : ->) : Nil
      @before_all.try &.each &.call
      @before_each.try &.each &.call(example)
      # proc = wrap_with_around_each_hooks(example, &block)
      # proc.run
      block.call
      @after_each.try &.each &.call(example)
      @after_all.try &.each &.call
    end

    private def wrap_with_around_each_hooks(example : Example, &block : ->)
      proc = example.to_proc(&block)
      @around_each.try do |hooks|
      end
      proc
    end
  end
end
