module Spectator::DSL
  # Standard example group builder.
  # Creates groups of examples and nested groups.
  class NestedExampleGroupBuilder < ExampleGroupBuilder
    # Creates a new group builder.
    # The value for *what* should be the context for the group.
    #
    # For example, in these samples:
    # ```
    # describe String do
    #   # ...
    #   context "with an empty string" do
    #     # ...
    #   end
    # end
    # ```
    # The value would be "String" for the describe block
    # and "with an empty string" for the context block.
    # Use a `Symbol` when referencing a type name.
    def initialize(@what : Symbol | String)
    end

    # Builds the example group.
    # A new `NestedExampleGroup` will be returned
    # which can have instances of `Example` and `ExampleGroup` nested in it.
    # The *parent* should be the group that contains this group.
    # The *sample_values* will be given to all of the examples (and groups) nested in this group.
    def build(parent : ExampleGroup, sample_values : Internals::SampleValues) : NestedExampleGroup
      NestedExampleGroup.new(@what, parent, hooks, conditions).tap do |group|
        # Set the group's children to built versions of the children from this instance.
        group.children = @children.map do |child|
          # Build the child and up-cast to prevent type errors.
          child.build(group, sample_values).as(ExampleComponent)
        end
      end
    end
  end
end
