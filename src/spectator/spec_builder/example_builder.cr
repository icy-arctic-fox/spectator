module Spectator::SpecBuilder
  class ExampleBuilder
    def initialize(@wrapper : TestWrapper)
    end

    def build(group)
      RunnableExample.new(group, @wrapper).as(ExampleComponent)
    end
  end
end
