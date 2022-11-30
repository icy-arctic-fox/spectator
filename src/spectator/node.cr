require "./label"
require "./location"
require "./metadata"

module Spectator
  # A single item in a test spec.
  # This is commonly an `Example` or `ExampleGroup`,
  # but can be anything that should be iterated over when running the spec.
  abstract class Node
    # Default text used if none was given by the user for skipping a node.
    DEFAULT_PENDING_REASON = "No reason given"

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

    # User-defined tags and values used for filtering and behavior modification.
    def metadata : Metadata
      @metadata ||= Metadata.new
    end

    # Creates the node.
    # The *name* describes the purpose of the node.
    # It can be a `Symbol` to describe a type.
    # The *location* tracks where the node exists in source code.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    def initialize(@name : Label = nil, @location : Location? = nil, @metadata : Metadata? = nil)
    end

    # Indicates whether the node has completed.
    abstract def finished? : Bool

    # Checks if the node has been marked as pending.
    # Pending items should be skipped during execution.
    def pending?
      return false unless md = @metadata

      md.has_key?(:pending) || md.has_key?(:skip)
    end

    # Gets the reason the node has been marked as pending.
    def pending_reason
      return DEFAULT_PENDING_REASON unless md = @metadata

      md[:pending]? || md[:skip]? || md[:reason]? || DEFAULT_PENDING_REASON
    end

    # Retrieves just the tag names applied to the node.
    def tags
      if md = @metadata
        Tags.new(md.keys)
      else
        Tags.new
      end
    end

    # Non-nil name used to show the node name.
    def display_name
      @name || "<anonymous>"
    end

    # Constructs the full name or description of the node.
    # This prepends names of groups this node is part of.
    def to_s(io : IO) : Nil
      display_name.to_s(io)
    end

    # Exposes information about the node useful for debugging.
    def inspect(io : IO) : Nil
      # Full node name.
      io << '"' << self << '"'

      # Add location if it's available.
      if (location = self.location)
        io << " @ " << location
      end
    end
  end
end
