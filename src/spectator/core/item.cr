require "./location_range"

module Spectator::Core
  # Base class for all items in the test suite.
  abstract class Item
    # The description of the item.
    # This may be nil if the item does not have a description.
    getter! description : String

    # The full description of the item.
    # This is a combination of all parent descriptions and this item's description.
    def full_description : String
      String.build do |io|
        build_full_description(io)
      end
    end

    protected def build_full_description(io : IO) : Nil
      parent?.try &.build_full_description(io)
      if description = description?
        io << ' ' << description
      end
    end

    # The location of the item in the source code.
    # This may be nil if the item does not have a location,
    # such as if it was dynamically generated.
    getter! location : LocationRange

    # Context (the example group) the item belongs to.
    getter! parent : Context

    def parent=(@parent : Context)
    end

    # Creates a new item.
    # The *description* can be a string, nil, or any other object.
    # When it is a string or nil, it will be stored as-is.
    # Any other types will be converted to a string by calling `#inspect` on it.
    def initialize(description = nil, @location = nil)
      @description = description.is_a?(String) ? description : description.try &.inspect
    end
  end
end
