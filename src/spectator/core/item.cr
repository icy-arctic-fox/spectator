require "./context"
require "./location_range"

module Spectator::Core
  # Base class for all items in the test suite.
  abstract class Item
    # The description of the item.
    # This may be nil if the item does not have a description.
    getter! description : String

    # The full description of the item.
    # This is a combination of all parent descriptions and this item's description.
    def full_description : String?
      return unless description?
      String.build do |io|
        full_description(io)
      end
    end

    # Appends the parent's description and this item's description to the given *io*.
    def full_description(io : IO) : Nil
      return unless description?
      if parent = parent?
        parent.full_description(io)
        io << ' ' if parent.description?
      end
      io << description
    end

    # The location of the item in the source code.
    # This may be nil if the item does not have a location,
    # such as if it was dynamically generated.
    getter! location : LocationRange

    # Context (the example group) the item belongs to.
    getter! parent : Context

    # Sets the context (the example group) the item belongs to.
    # NOTE: It is important that the context should be made aware that this item is a child.
    def parent=(@parent : Context)
    end

    # Clears the context (the example group) the item belongs to.
    # NOTE: It is important that the context should be made aware that this item is no longer a child.
    def parent=(@parent : Nil)
    end

    # Indicates if the item has been run.
    abstract def run? : Bool

    # Creates a new item.
    # The *description* can be a string, nil, or any other object.
    # When it is a string or nil, it will be stored as-is.
    # Any other types will be converted to a string by calling `#inspect` on it.
    def initialize(description = nil, @location = nil)
      @description = description.is_a?(String) ? description : description.try &.inspect
    end
  end
end
