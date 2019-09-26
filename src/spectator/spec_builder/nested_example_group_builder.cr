require "../test_context"
require "./example_group_builder"

module Spectator::SpecBuilder
  class NestedExampleGroupBuilder < ExampleGroupBuilder
    def initialize(@description : String | Symbol, @source : Source)
    end

    def build(parent_group)
      context = TestContext.new(parent_group.context, build_hooks, parent_group.context.values)
      NestedExampleGroup.new(@description, @source, parent_group, context).tap do |group|
        group.children = children.map do |child|
          child.build(group).as(ExampleComponent)
        end
      end
    end
  end
end
