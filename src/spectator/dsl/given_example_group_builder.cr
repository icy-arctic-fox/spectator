require "./example_group_builder"

module Spectator::DSL
  class GivenExampleGroupBuilder(T) < ExampleGroupBuilder
    def initialize(what : String, @collection : Array(T), @symbol : Symbol)
      super(what)
    end

    def build(parent : ExampleGroup?, sample_values : Internals::SampleValues) : ExampleGroup
      ExampleGroup.new(@what, parent, build_hooks).tap do |group|
        group.children = @collection.map do |value|
          build_sub_group(group, sample_values, value).as(ExampleGroup::Child)
        end
      end
    end

    private def build_sub_group(parent : ExampleGroup, sample_values : Internals::SampleValues, value : T) : ExampleGroup
      sub_values = sample_values.add(@symbol, @symbol.to_s, value)
      ExampleGroup.new(value.to_s, parent, ExampleHooks.empty).tap do |group|
        group.children = @children.map do |child|
          child.build(group, sub_values).as(ExampleGroup::Child)
        end
      end
    end
  end
end
