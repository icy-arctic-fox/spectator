module Spectator::DSL
  class RootExampleGroupBuilder < ExampleGroupBuilder
    def initialize
      super("ROOT")
    end
    
    def build(sample_values : Internals::SampleValues) : ExampleGroup
      RootExampleGroup.new(build_hooks).tap do |group|
        group.children = @children.map do |child|
          child.build(group, sample_values).as(ExampleGroup::Child)
        end
      end
    end
  end
end
