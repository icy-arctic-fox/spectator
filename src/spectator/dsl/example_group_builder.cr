module Spectator::DSL
  abstract class ExampleGroupBuilder
    alias Child = ExampleFactory | NestedExampleGroupBuilder

    @children = [] of Child
    @before_all_hooks = [] of ->
    @before_each_hooks = [] of ->
    @after_all_hooks = [] of ->
    @after_each_hooks = [] of ->
    @around_each_hooks = [] of Proc(Nil) ->

    def add_child(child : Child)
      @children << child
    end

    def add_before_all_hook(block : ->) : Nil
      @before_all_hooks << block
    end

    def add_before_each_hook(block : ->) : Nil
      @before_each_hooks << block
    end

    def add_after_all_hook(block : ->) : Nil
      @after_all_hooks << block
    end

    def add_after_each_hook(block : ->) : Nil
      @after_each_hooks << block
    end

    def add_around_each_hook(block : Proc(Nil) ->) : Nil
      @around_each_hooks << block
    end

    private def hooks
      ExampleHooks.new(
        @before_all_hooks,
        @before_each_hooks,
        @after_all_hooks,
        @after_each_hooks,
        @around_each_hooks
      )
    end
  end
end
