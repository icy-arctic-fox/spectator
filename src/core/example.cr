module Spectator
  # Information about a test case and functionality for running it.
  class Example
    # Name of the example.
    # This may be nil if the example does not have a name.
    # In that case, the description of the first matcher executed in the example should be used.
    property! name : String

    # Creates a new example.
    # The *name* may be nil if the example has no name.
    def initialize(@name = nil, &@block : Example -> Nil)
    end

    # Runs the example.
    def run
      @block.call(self)
    end

    # Constructs a string representation of the example.
    # The name will be used if it is set, otherwise the example will be anonymous.
    def to_s(io : IO) : Nil
      if (name = @name)
        io << name
      else
        io << "<Anonymous Example>"
      end
    end
  end
end
