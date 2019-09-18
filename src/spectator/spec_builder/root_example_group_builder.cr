require "./example_group_builder"

module Spectator::SpecBuilder
  class RootExampleGroupBuilder < ExampleGroupBuilder
    def build
      RootExampleGroup.new(context).tap do |group|
        group.children = children.map do |child|
          child.build(group).as(ExampleComponent)
        end
      end
    end
  end
end
