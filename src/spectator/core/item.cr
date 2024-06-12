module Spectator::Core
  # Base class for all items in the test suite.
  abstract class Item
    # The description of the item.
    getter description : String

    # The location of the item in the source code.
    # This may be nil if the item does not have a location,
    # such as if it was dynamically generated.
    getter! location : LocationRange

    # Creates a new item.
    def initialize(@description)
    end

    # Constructs a string representation of the item.
    def to_s(io : IO) : Nil
      io << @description
    end
  end
end
