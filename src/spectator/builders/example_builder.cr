module Spectator::Builders
  class ExampleBuilder
    def initialize(@wrapper : TestWrapper)
    end

    def build(group)
      RunnableExample.new(group, @wrapper).as(ExampleComponent)
    end
  end
end
