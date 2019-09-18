require "./example_group_builder"

module Spectator::SpecBuilder
  class NestedExampleGroupBuilder < ExampleGroupBuilder
    def initialize(@what : String | Symbol)
    end

    def build(group)
      NestedExampleGroup.new(@what, group, context).tap do |group|
        group.children = children.map do |child|
          child.build(group).as(ExampleComponent)
        end
      end
    end
  end
end
