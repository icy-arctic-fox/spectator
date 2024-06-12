module Spectator::Core
  # Information about a group of examples and functionality for running them.
  # The group can be nested.
  class ExampleGroup
    # Name of the group.
    # This may be nil if the group does not have a name.
    property! name : String

    getter examples = [] of Example

    # Creates a new group.
    # The *name* may be nil if the group has no name.
    def initialize(@name = nil)
    end

    # Constructs a string representation of the group.
    # The name will be used if it is set, otherwise the group will be anonymous.
    def to_s(io : IO) : Nil
      if name = @name
        io << name
      else
        io << "<Anonymous Context>"
      end
    end
  end
end
