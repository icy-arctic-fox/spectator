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

      def add_before_all_hook(&block : ->) : Nil
        @before_all_hooks << block
      end

      def add_before_each_hook(&block : ->) : Nil
        @before_each_hooks << block
      end

      def add_after_all_hook(&block : ->) : Nil
        @after_all_hooks << block
      end

      def add_after_each_hook(&block : ->) : Nil
        @after_each_hooks << block
      end

      def add_around_each_hook(&block : Proc(Nil) ->) : Nil
        @around_each_hooks << block
      end

      def build(parent : ExampleGroup?, locals : Hash(Symbol, ValueWrapper)) : ExampleGroup
        ExampleGroup.new(@what, parent).tap do |group|
          children = @children.map do |child|
            child.build(group, locals).as(ExampleGroup::Child)
          end
          group.children = children
        end
      end
    end
  end
end
