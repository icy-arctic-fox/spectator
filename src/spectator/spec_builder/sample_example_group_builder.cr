require "./nested_example_group_builder"

module Spectator::SpecBuilder
  class SampleExampleGroupBuilder < NestedExampleGroupBuilder
    def initialize(@what : String | Symbol)
      @id = :TODO
    end

    def build(parent_group)
      context = TestContext.new(parent_group.context, build_hooks, parent_group.context.values)
      NestedExampleGroup.new(@what, parent_group, context).tap do |group|
        group.children = [:TODO].map do |element|
          build_sub_group(group, element).as(ExampleComponent)
        end
      end
    end

    private def build_sub_group(parent_group, element)
      values = parent_group.context.values.add(@id, @what.to_s, element)
      context = TestContext.new(parent_group.context, ExampleHooks.empty, values)
      NestedExampleGroup.new("TODO", parent_group, context).tap do |group|
        group.children = children.map do |child|
          child.build(group).as(ExampleComponent)
        end
      end
    end
  end
end
