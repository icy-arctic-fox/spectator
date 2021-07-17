require "./example_group"

module Spectator
  class ExampleGroupIteration(T) < ExampleGroup
    getter item : T

    def initialize(@item : T, name : Label = nil, location : Location? = nil,
                   group : ExampleGroup? = nil, metadata : Metadata = Metadata.new)
      super(name, location, group, metadata)
    end
  end
end
