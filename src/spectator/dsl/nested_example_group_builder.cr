module Spectator::DSL
  class NestedExampleGroupBuilder < ExampleGroupBuilder
    def initialize(@what : String)
    end

    def add_child(child : Child) : Nil
      @children << child
    end

    def build(parent : ExampleGroup, sample_values : Internals::SampleValues) : NestedExampleGroup
      NestedExampleGroup.new(@what, parent, hooks).tap do |group|
        group.children = @children.map do |child|
          child.build(group, sample_values).as(ExampleComponent)
        end
      end
    end
  end
end
