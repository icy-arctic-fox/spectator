module Spectator::DSL
  class RootExampleGroupBuilder < NestedExampleGroupBuilder
    def initialize
      super("ROOT")
    end

    def build(sample_values : Internals::SampleValues) : RootExampleGroup
      RootExampleGroup.new(build_hooks).tap do |group|
        group.children = @children.map do |child|
          child.build(group, sample_values).as(ExampleComponent)
        end
      end
    end
  end
end
