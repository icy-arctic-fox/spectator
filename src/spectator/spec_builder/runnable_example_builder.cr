require "./example_builder"

module Spectator::SpecBuilder
  class RunnableExampleBuilder < ExampleBuilder
    def build(group) : ExampleComponent
      wrapper = build_test_wrapper(group)
      RunnableExample.new(group, wrapper).as(ExampleComponent)
    end
  end
end
