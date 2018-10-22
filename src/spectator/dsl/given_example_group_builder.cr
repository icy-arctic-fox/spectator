require "./nested_example_group_builder"

module Spectator::DSL
  class GivenExampleGroupBuilder(T) < NestedExampleGroupBuilder
    def initialize(what : String, @collection : Array(T), @symbol : Symbol)
      super(what)
    end

    def build(parent : ExampleGroup, sample_values : Internals::SampleValues) : NestedExampleGroup
      NestedExampleGroup.new(@what, parent, hooks).tap do |group|
        group.children = @collection.map do |value|
          build_sub_group(group, sample_values, value).as(ExampleComponent)
        end
      end
    end

    private def build_sub_group(parent : ExampleGroup, sample_values : Internals::SampleValues, value : T) : NestedExampleGroup
      sub_values = sample_values.add(@symbol, @symbol.to_s, value) # TODO: Use real name instead of symbol as string.
      NestedExampleGroup.new(value.to_s, parent, ExampleHooks.empty).tap do |group|
        group.children = @children.map do |child|
          child.build(group, sub_values).as(ExampleComponent)
        end
      end
    end
  end
end
