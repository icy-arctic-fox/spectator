require "./context"
require "./example"
require "./item"

module Spectator::Core
  # Information about a group of examples and functionality for running them.
  # The group can be nested.
  class ExampleGroup < Item
    include Context

    def self.new(description = nil, location : LocationRange? = nil, &)
      group = new(description, location)
      with group yield group
      group
    end

    def context(description, &)
      self.class.new(description).tap do |child|
        add_child(child)
        with child yield
      end
    end

    def specify(description, &block : Example ->) : Example
      example = Example.new(description, &block)
      add_child(example)
      example
    end

    @children = [] of Item

    def add_child(child : Item) : Nil
      # Attempt to remove the child from its previous parent.
      child.parent?.try do |prev_parent|
        prev_parent.remove_child(child) if prev_parent.responds_to?(:remove_child)
      end

      @children << child
      child.parent = self
    end

    def remove_child(child : Item) : Nil
      # Don't remove the child if it's not ours.
      return unless child.parent? == self

      @children.delete(child)
      child.parent = nil
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
