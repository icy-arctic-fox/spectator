require "./nested_example_group_builder"

module Spectator::SpecBuilder
  class SampleExampleGroupBuilder(T) < NestedExampleGroupBuilder
    def initialize(what : String | Symbol, @id : Symbol, @label : String, @collection_builder : TestValues -> Array(T))
      super(what)
    end

    def build(parent_group)
      values = parent_group.context.values
      collection = @collection_builder.call(values)
      context = TestContext.new(parent_group.context, build_hooks, values)
      NestedExampleGroup.new(@what, parent_group, context).tap do |group|
        group.children = collection.map do |element|
          build_sub_group(group, element).as(ExampleComponent)
        end
      end
    end

    private def build_sub_group(parent_group, element)
      values = parent_group.context.values.add(@id, @what.to_s, element)
      context = TestContext.new(parent_group.context, ExampleHooks.empty, values)
      NestedExampleGroup.new("#{@label} = #{element.inspect}", parent_group, context).tap do |group|
        group.children = children.map do |child|
          child.build(group).as(ExampleComponent)
        end
      end
    end
  end
end
