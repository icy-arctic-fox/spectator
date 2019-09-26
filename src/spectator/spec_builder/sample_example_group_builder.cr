require "./nested_example_group_builder"

module Spectator::SpecBuilder
  class SampleExampleGroupBuilder < NestedExampleGroupBuilder
    def initialize(@what : String)
    end

    def build(parent_group)
      context = TestContext.new(parent_group.context, build_hooks)
      NestedExampleGroup.new(@what, parent_group, context).tap do |group|
        group.children = [:TODO].map do |element|
          build_sub_group(group, element).as(ExampleComponent)
        end
      end
    end

    private def build_sub_group(parent_group, element)
      context = TestContext.new(parent_group.context, ExampleHooks.empty)
      NestedExampleGroup.new("TODO", parent_group, context).tap do |group|
        group.children = children.map do |child|
          child.build(group).as(ExampleComponent)
        end
      end
    end
  end
end
