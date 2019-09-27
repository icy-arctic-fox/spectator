require "./example_builder"

module Spectator::SpecBuilder
  class PendingExampleBuilder < ExampleBuilder
    def build(group) : ExampleComponent
      wrapper = build_test_wrapper(group)
      PendingExample.new(group, wrapper).as(ExampleComponent)
    end
  end
end
