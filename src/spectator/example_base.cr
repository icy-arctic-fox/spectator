require "./example_group"
require "./result"
require "./source"

module Spectator
  # Common base type for all examples.
  abstract class ExampleBase
    # Location of the example in source code.
    getter! source : Source

    # User-provided name or description of the test.
    # This does not include the group name or descriptions.
    # Use `#to_s` to get the full name.
    #
    # This value will be nil if no name was provided.
    # In this case, the name should be set
    # to the description of the first matcher that runs in the example.
    #
    # If this value is a `Symbol`, the user specified a type for the name.
    getter! name : String | Symbol

    # Group the example belongs to.
    # Hooks are used from this group.
    getter! group : ExampleGroup

    # Assigns the group the example belongs to.
    # If the example already belongs to a group,
    # it will be removed from the previous group before adding it to the new group.
    def group=(group : ExampleGroup?)
      if (previous = @group)
        previous.remove_example(self)
      end
      group.add_example(self) if group
      @group = group
    end

    # Creates the base of the example.
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *source* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    def initialize(@name : String | Symbol? = nil, @source : Source? = nil, group : ExampleGroup? = nil)
      # Ensure group is linked.
      self.group = group
    end

    # Indicates whether the example already ran.
    abstract def finished? : Bool

    # Retrieves the result of the last time the example ran.
    # This will be nil if the example hasn't run,
    # and should not be nil if it has.
    abstract def result? : Result?

    # Retrieves the result of the last time the example ran.
    # Raises an error if the example hasn't run.
    def result : Result
      result? || raise(NilAssertionError("Example has no result"))
    end

    # Constructs the full name or description of the example.
    # This prepends names of groups this example is part of.
    def to_s(io)
      name = @name

      # Prefix with group's full name if the example belongs to a group.
      if (group = @group)
        group.to_s(io)

        # Add padding between the group name and example name,
        # only if the names appear to be symbolic.
        if group.name.is_a?(Symbol) && name.is_a?(String)
          io << ' ' unless name.starts_with?('#') || name.starts_with?('.')
        end
      end

      name.to_s(io)
    end

    # Exposes information about the example useful for debugging.
    def inspect(io)
      raise NotImplementedError.new("#inspect")
    end
  end
end
