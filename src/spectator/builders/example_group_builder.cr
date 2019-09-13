require "./example_builder"

module Spectator::Builders
  abstract class ExampleGroupBuilder
    alias Child = NestedExampleGroupBuilder | ExampleBuilder

    private getter children = [] of Child

    def add_child(child : Child)
      @children << child
    end
  end
end
