require "./example_component"

module Spectator
  abstract class ExampleGroup < ExampleComponent
    include Enumerable(ExampleComponent)
    include Iterable(ExampleComponent)

    def initialize(@hooks : ExampleHooks)
      @before_all_hooks_run = false
      @after_all_hooks_run = false
    end

    getter! children : Array(ExampleComponent)

    def children=(children : Array(ExampleComponent))
      raise "Attempted to reset example group children" if @children
      @children = children
      @example_count = children.sum(&.example_count)
    end

    def each
      children.each do |child|
        yield child
      end
    end

    def each : Iterator(ExampleComponent)
      children.each
    end

    getter example_count = 0

    def [](index : Int) : Example
      offset = check_bounds(index)
      find_nested(offset)
    end

    private def check_bounds(index)
      if index < 0
        raise IndexError.new if index < -example_count
        index + example_count
      else
        raise IndexError.new if index >= example_count
        index
      end
    end

    private def find_nested(index)
      offset = index
      child = children.each do |child|
        count = child.example_count
        break child if offset < count
        offset -= count
      end
      # It should be impossible to get `nil` here,
      # provided the bounds check and example counts are correct.
      child.not_nil![offset]
    end

    def finished? : Bool
      children.all?(&.finished?)
    end

    def run_before_all_hooks : Nil
      unless @before_all_hooks_run
        @hooks.run_before_all
        @before_all_hooks_run = true
      end
    end

    def run_before_each_hooks : Nil
      @hooks.run_before_each
    end

    def run_after_all_hooks : Nil
      unless @after_all_hooks_run
        if finished?
          @hooks.run_after_all
          @after_all_hooks_run = true
        end
      end
    end

    def run_after_each_hooks : Nil
      @hooks.run_after_each
    end

    def wrap_around_each_hooks(&block : ->) : ->
      @hooks.wrap_around_each(&block)
    end
  end
end
