require "../label"
require "../source"

module Spectator
  class Spec
    # A single item in a test spec.
    # This is commonly an `Example` or `ExampleGroup`,
    # but can be anything that should be iterated over when running the spec.
    abstract class Node
      # User-defined keywords used for filtering and behavior modification.
      alias Tags = Set(String)

      # Location of the node in source code.
      getter! source : Source

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

      # Group the node belongs to.
      getter! group : ExampleGroup

      # User-defined keywords used for filtering and behavior modification.
      getter tags : Tags

      # Assigns the node to the specified *group*.
      # This is an internal method and should only be called from `ExampleGroup`.
      # `ExampleGroup` manages the association of nodes to groups.
      protected setter group : ExampleGroup?

      # Creates the node.
      # The *name* describes the purpose of the node.
      # It can be a `Symbol` to describe a type.
      # The *source* tracks where the node exists in source code.
      # The node will be assigned to *group* if it is provided.
      # A set of *tags* can be used for filtering and modifying example behavior.
      def initialize(@name : Label = nil, @source : Source? = nil,
        group : ExampleGroup? = nil, @tags : Tags = Tags.new)
        # Ensure group is linked.
        group << self if group
      end

      # Indicates whether the node has completed.
      abstract def finished? : Bool

      # Constructs the full name or description of the node.
      # This prepends names of groups this node is part of.
      def to_s(io)
        name = @name

        # Prefix with group's full name if the node belongs to a group.
        if (group = @group)
          group.to_s(io)

          # Add padding between the node names
          # only if the names don't appear to be symbolic.
          # Skip blank group names (like the root group).
          io << ' ' unless !group.name? || # ameba:disable Style/NegatedConditionsInUnless
                           (group.name?.is_a?(Symbol) && name.is_a?(String) &&
                           (name.starts_with?('#') || name.starts_with?('.')))
        end

        name.to_s(io)
      end
    end
  end
end
