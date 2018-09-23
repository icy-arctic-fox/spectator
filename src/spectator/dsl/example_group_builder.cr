module Spectator
  module DSL
    class ExampleGroupBuilder
      alias Child = ExampleFactory | ExampleGroupBuilder

      @children = [] of Child
      @before_all_hooks = [] of ->
      @before_each_hooks = [] of ->
      @after_all_hooks = [] of ->
      @after_each_hooks = [] of ->
      @around_each_hooks = [] of Proc(Nil) ->

      def initialize(@what : String)
      end

      def add_child(child : Child) : Nil
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

      def build(parent : ExampleGroup?, sample_values : Internals::SampleValues) : ExampleGroup
        ExampleGroup.new(@what, parent, build_hooks).tap do |group|
          children = @children.map do |child|
            child.build(group, sample_values).as(ExampleGroup::Child)
          end
          group.children = children
        end
      end

      private def build_hooks
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
end
