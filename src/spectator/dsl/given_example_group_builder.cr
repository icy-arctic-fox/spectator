require "./example_group_builder"

module Spectator
  module DSL
    class GivenExampleGroupBuilder < ExampleGroupBuilder

      def initialize(what : String, @collection : Array(ValueWrapper))
        super(what)
      end

      def build(parent : ExampleGroup?, locals : Hash(Symbol, ValueWrapper)) : ExampleGroup
        ExampleGroup.new(@what, parent).tap do |group|
          children = [] of ExampleGroup::Child
          @collection.each do |value|
            iter_locals = locals.merge({:TODO => value})
            iter_children = @children.map do |child|
              child.build(group, iter_locals)
            end
            children.concat(iter_children)
          end
          group.children = children
        end
      end
    end
  end
end
