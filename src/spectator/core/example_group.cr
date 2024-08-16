require "./context"
require "./example"
require "./item"
require "./location_range"

module Spectator::Core
  # Information about a group of examples and functionality for running them.
  # The group can be nested.
  class ExampleGroup < Item
    include Context
    include Enumerable(Item)

    def self.new(description = nil, tags : TagModifiers? = nil, location : LocationRange? = nil, &)
      group = new(description, tags, location)
      with group yield group
      group
    end

    protected getter children = [] of Item

    def add_child(child : Item) : Nil
      # Attempt to remove the child from its previous parent.
      child.parent.try do |prev_parent|
        prev_parent.remove_child(child) if prev_parent.responds_to?(:remove_child)
      end

      @children << child
      child.parent = self
    end

    def remove_child(child : Item) : Nil
      @children.delete(child)

      # Disassociate the child only if it's ours.
      child.parent = nil if child.parent == self
    end

    def each(& : Item ->) : Nil
      stack = [self] of Item
      while item = stack.shift?
        yield item
        if item.is_a?(ExampleGroup)
          stack.concat(item.children)
        end
      end
    end

    def run : Array(Result)
      results = [] of Result
      @children.each do |child|
        result = child.run
        if result.is_a?(Indexable(Result))
          results.concat(result)
        else
          results << result
        end
      end
      results
    end

    # Indicates if all examples in the group (and subgroups) have been run.
    def run? : Bool
      @children.all? &.run?
    end

    def no_runs? : Bool
      @children.each do |child|
        if child.is_a?(ExampleGroup)
          return false unless child.no_runs?
        else
          return false if child.run?
        end
      end
      true
    end

    # Constructs a string representation of the group.
    # The description will be used if it is set, otherwise the group will be anonymous.
    def to_s(io : IO) : Nil
      if description = @description
        io << description
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
      io << " tags: "
      print_tags(io)
      io << " 0x"
      object_id.to_s(io, 16)
      io << '>'
    end
  end
end
