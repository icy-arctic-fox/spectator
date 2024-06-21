require "./context"
require "./item"

module Spectator::Core
  # Information about a group of examples and functionality for running them.
  # The group can be nested.
  class ExampleGroup < Item
    include Context

    def context(description, &)
      self.class.new(description).tap do |child|
        child.parent = self
        with child yield
      end
    end

    def self.new(description = nil, location : LocationRange? = nil, &)
      group = new(description, location)
      with group yield group
      group
    end

    # Constructs a string representation of the group.
    # The name will be used if it is set, otherwise the group will be anonymous.
    def to_s(io : IO) : Nil
      if name = @name
        io << name
      else
        io << "<Anonymous ExampleGroup>"
      end
    end

    def inspect(io : IO) : Nil
      io << "#<" << self.class << ' '
      if description = @description
        io << '"' << description << '"'
      else
        io << "Anonymous Example Group"
      end
      if location = @location
        io << " @ " << location
      end
      io << " 0x"
      object_id.to_s(io, 16)
      io << '>'
    end
  end
end
