module Spectator::Core
  class ExampleHook
    getter! location : LocationRange

    getter! exception : Exception

    def initialize(@location = nil, &@block : Example ->)
    end

    def initialize(@block : Example ->)
    end

    def call(example : Example)
      # Re-raise previous error if there was one.
      @exception.try { |ex| raise ex }

      begin
        @block.call(example)
      rescue ex
        @exception = ex
        raise ex
      end
    end
  end

  class ContextHook
    getter! location : LocationRange

    getter! exception : Exception

    @called = Atomic::Flag.new

    def initialize(@location = nil, &@block : ->)
    end

    def initialize(@block : ->)
    end

    def call
      # Ensure the hook is called once.
      called = @called.test_and_set
      # Re-raise previous error if there was one.
      @exception.try { |ex| raise ex }
      # Only call hook if it hasn't been called yet.
      return unless called

      begin
        @block.call
      rescue ex
        @exception = ex
        raise ex
      end
    end
  end

  class ExampleProcsyHook
    getter! location : LocationRange

    getter! exception : Exception

    def initialize(@location = nil, &@block : Example::Procsy ->)
    end

    def initialize(@block : Example::Procsy ->)
    end

    def call(example : Example)
      # Re-raise previous error if there was one.
      @exception.try { |ex| raise ex }

      procsy = example.to_proc
      begin
        @block.call(procsy)
      rescue ex
        @exception = ex
        raise ex
      end
    end
  end

  module Hooks
    def before_each(& : Example ->) : Nil
      hooks = @before_each ||= [] of ExampleHook
    end

    def after_each(& : Example ->)
      hooks = @after_each ||= [] of ExampleHook
    end

    def before_all(& : ->)
      hooks = @before_all ||= [] of ContextHook
    end

    def after_all(& : ->)
      hooks = @after_all ||= [] of ContextHook
    end

    def around_each(& : Example ->)
    end

    def around_all(& : ->)
    end

    def run_with_hooks(example : Example, & : ->) : Nil
      @before_all.try &.each &.call
      @before_each.try &.each &.call(example)
      proc = wrap_with_around_each_hooks(example) { yield }
      proc.run
      @after_each.try &.each &.call(example)
      @after_all.try &.each &.call
    end

    private def wrap_with_around_each_hooks(example : Example, & : ->)
      proc = Example::Procsy.new(example) { yield }
      @around_each.try do |hooks|
        proc = Example::Procsy.new(example, &proc)
      end
      proc
    end
  end
end
