require "./example_group_builder"

module Spectator
  module DSL
    class GivenExampleGroupBuilder < ExampleGroupBuilder

      def initialize(what : String, @collection : Array(Internals::ValueWrapper), @symbol : Symbol)
        super(what)
      end

      def build(parent : ExampleGroup?, sample_values : Internals::SampleValues) : ExampleGroup
        ExampleGroup.new(@what, parent, build_hooks).tap do |group|
          children = [] of ExampleGroup::Child
          @collection.each do |value|
            iter_values = sample_values.add(@symbol, @symbol.to_s, value)
            iter_children = @children.map do |child|
              child.build(group, iter_values)
            end
            children.concat(iter_children)
          end
          group.children = children
        end
      end
    end
  end
end
