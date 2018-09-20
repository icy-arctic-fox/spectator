require "./example"

module Spectator
  class ExampleGroup
    ROOT = ExampleGroup.new("ROOT")

    getter what : String
    getter parent : ExampleGroup?
    getter before_all_hooks = [] of ->
    getter before_each_hooks = [] of ->
    getter after_all_hooks = [] of ->
    getter after_each_hooks = [] of ->
    getter around_each_hooks = [] of Proc(Nil) ->
    getter children = [] of ExampleFactory | ExampleGroup

    @before_all_hooks_run = false
    @after_all_hooks_run = false

    def initialize(@what, @parent = nil)
      if (parent = @parent)
        parent.children << self
      end
    end

    def examples : Enumerable(ExampleFactory)
      @children.select { |child| child.is_a?(ExampleFactory) }.map { |child| child.unsafe_as(ExampleFactory) }
    end

    def groups : Enumerable(ExampleGroup)
      @children.select { |child| child.is_a?(ExampleGroup) }.map { |child| child.unsafe_as(ExampleGroup) }
    end

    def all_examples
      Array(Example).new.tap do |array|
        add_examples(array)
      end
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

    def add_examples(array : Array(Example))
      @children.each do |child|
        if child.is_a?(ExampleFactory)
          array << child.build
        else
          array.concat(child.all_examples)
        end
      end
    end
  end
end
