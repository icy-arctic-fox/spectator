require "./example_group"
require "./label"
require "./location"
require "./metadata"

module Spectator
  # Collection of examples and sub-groups for a single iteration of an iterative example group.
  class ExampleGroupIteration(T) < ExampleGroup
    # Item for this iteration of the example groups.
    getter item : T

    # Creates the example group iteration.
    # The element for the current iteration is provided by *item*.
    # The *name* describes the purpose of the group.
    # It can be a `Symbol` to describe a type.
    # This is typically a stringified form of *item*.
    # The *location* tracks where the group exists in source code.
    # This group will be assigned to the parent *group* if it is provided.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    def initialize(@item : T, name : Label = nil, location : Location? = nil,
                   group : ExampleGroup? = nil, metadata : Metadata? = nil)
      super(name, location, group, metadata)
    end
  end
end
