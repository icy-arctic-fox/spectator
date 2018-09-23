require "./example"

module Spectator
  class ExampleGroup
    alias Child = Example | ExampleGroup

    getter what : String

    getter! parent : ExampleGroup

    private getter! children : Array(Child)
    setter children

    private getter hooks : ExampleHooks

    def initialize(@what, @parent, @hooks)
    end

    def examples : Enumerable(Example)
      children.select { |child| child.is_a?(Example) }.map { |child| child.unsafe_as(Example) }
    end

    def groups : Enumerable(ExampleGroup)
      children.select { |child| child.is_a?(ExampleGroup) }.map { |child| child.unsafe_as(ExampleGroup) }
    end

    def example_count
      children.sum do |child|
        child.is_a?(Example) ? 1 : child.example_count
      end
    end

    def all_examples
      Array(Example).new(example_count).tap do |array|
        children.each do |child|
          if child.is_a?(Example)
            array << child
          else
            array.concat(child.all_examples)
          end
        end
      end
    end

    def run_before_all_hooks
      if (parent = @parent)
        parent.run_before_all_hooks
      end
      unless @before_all_hooks_run
        hooks.run_before_all
        @before_all_hooks_run = true
      end
    end

    def run_before_each_hooks
      if (parent = @parent)
        parent.run_before_each_hooks
      end
      hooks.run_before_each
    end

    def run_after_all_hooks
      unless @after_all_hooks_run
        if all_examples.all?(&.finished?)
          hooks.run_after_all
          @after_all_hooks_run = true
        end
      end
      if (parent = @parent)
        parent.run_after_all_hooks
      end
    end

    def run_after_each_hooks
      hooks.run_after_each
      if (parent = @parent)
        parent.run_after_each_hooks
      end
    end

    def wrap_around_each_hooks(&block : ->)
      wrapper = hooks.wrap_around_each(&block)
      if (parent = @parent)
        wrapper = parent.wrap_around_each_hooks(&wrapper)
      end
      wrapper
    end
  end
end
