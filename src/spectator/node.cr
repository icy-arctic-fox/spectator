require "./label"
require "./location"
require "./tags"

module Spectator
  # A single item in a test spec.
  # This is commonly an `Example` or `ExampleGroup`,
  # but can be anything that should be iterated over when running the spec.
  abstract class Node
    # Location of the node in source code.
    getter! location : Location

    # User-provided name or description of the node.
    # This does not include the group name or descriptions.
    # Use `#to_s` to get the full name.
    #
    # This value will be nil if no name was provided.
    # In this case, and the node is a runnable example,
    # the name should be set to the description
    # of the first matcher that runs in the test case.
    #
    # If this value is a `Symbol`, the user specified a type for the name.
    getter! name : Label

    # Updates the name of the node.
    protected def name=(@name : String)
    end

    # User-defined keywords used for filtering and behavior modification.
    getter tags : Tags

    # Creates the node.
    # The *name* describes the purpose of the node.
    # It can be a `Symbol` to describe a type.
    # The *location* tracks where the node exists in source code.
    # A set of *tags* can be used for filtering and modifying example behavior.
    def initialize(@name : Label = nil, @location : Location? = nil, @tags : Tags = Tags.new)
    end

    # Indicates whether the node has completed.
    abstract def finished? : Bool

    # Checks if the node has been marked as pending.
    # Pending items should be skipped during execution.
    def pending?
      tags.has_key?(:pending) || tags.has_key?(:skip)
    end

    # Constructs the full name or description of the node.
    # This prepends names of groups this node is part of.
    def to_s(io)
      (@name || "<anonymous>").to_s(io)
    end

    # Exposes information about the node useful for debugging.
    def inspect(io)
      # Full node name.
      io << '"' << self << '"'

      # Add location if it's available.
      if (location = self.location)
        io << " @ " << location
      end
    end
  end
end
