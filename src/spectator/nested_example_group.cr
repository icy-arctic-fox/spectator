require "./example_group"

module Spectator
  # A collection of examples and other example groups.
  # This group can be nested under other groups.
  class NestedExampleGroup < ExampleGroup
    # Description from the user of the group's contents.
    # This is a symbol when referencing a type.
    getter what : Symbol | String

    # Group that this is nested in.
    getter parent : ExampleGroup

    # Creates a new example group.
    # The *what* argument is a description from the user.
    # The *parent* should contain this group.
    # After creating this group, the parent's children should be updated.
    # The parent's children must contain this group,
    # otherwise there may be unexpected behavior.
    # The *hooks* are stored to be triggered later.
    def initialize(@what, @parent, context)
      super(context)
    end

    # Indicates wheter the group references a type.
    def symbolic? : Bool
      @what.is_a?(Symbol)
    end

    # Creates a string representation of the group.
    # The string consists of `#what` appended to the parent.
    # This results in a string like:
    # ```text
    # Foo#bar does something
    # ```
    # for the following structure:
    # ```
    # describe Foo do
    #   describe "#bar" do
    #     it "does something" do
    #       # ...
    #     end
    #   end
    # end
    # ```
    def to_s(io)
      parent.to_s(io)
      io << ' ' unless (symbolic? || parent.is_a?(RootExampleGroup)) && parent.symbolic?
      io << what
    end
  end
end
