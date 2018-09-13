require "./example"

module Spectator
  class Context
    ROOT = Context.new("ROOT")

    getter what : String
    getter parent : Context?
    getter examples = [] of Example
    getter contexts = [] of Context
    getter before_all_hooks = [] of ->
    getter before_each_hooks = [] of ->
    getter after_all_hooks = [] of ->
    getter after_each_hooks = [] of ->
    getter around_each_hooks = [] of Proc(Nil) ->

    @before_all_hooks_run = false
    @after_all_hooks_run = false

    def initialize(@what, @parent = nil)
      if (parent = @parent)
        parent.contexts << self
      end
    end

    def all_examples
      add_examples
    end

    def run_before_all_hooks
      if (parent = @parent)
        parent.run_before_all_hooks
      end
      unless @before_all_hooks_run
        @before_all_hooks.each do |hook|
          hook.call
        end
        @before_all_hooks_run = true
      end
    end

    def run_before_each_hooks
      if (parent = @parent)
        parent.run_before_each_hooks
      end
      @before_each_hooks.each do |hook|
        hook.call
      end
    end

    def run_after_all_hooks
      unless @after_all_hooks_run
        if all_examples.all?(&.finished?)
          @after_all_hooks.each do |hook|
            hook.call
          end
          @after_all_hooks_run = true
        end
      end
      if (parent = @parent)
        parent.run_after_all_hooks
      end
    end

    def run_after_each_hooks
      @after_each_hooks.each do |hook|
        hook.call
      end
      if (parent = @parent)
        parent.run_after_each_hooks
      end
    end

    def wrap_around_each_hooks(&block : ->)
      wrapper = block
      @around_each_hooks.reverse_each do |hook|
        wrapper = wrap_proc(hook, wrapper)
      end
      if (parent = @parent)
        wrapper = parent.wrap_around_each_hooks(&wrapper)
      end
      wrapper
    end

    private def wrap_proc(inner : Proc(Nil) ->, wrapper : ->)
      -> { inner.call(wrapper) }
    end

    protected def add_examples(array = [] of Example)
      array.concat(@examples)
      contexts.each do |context|
        context.add_examples(array)
      end
      array
    end
  end
end
