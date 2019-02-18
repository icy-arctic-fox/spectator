module Spectator::DSL
  # Top-level example group builder.
  # There should only be one instance of this class,
  # and it should be at the top of the spec "tree".
  class RootExampleGroupBuilder < ExampleGroupBuilder
    # Creates a `RootExampleGroup` which can have instances of `Example` and `ExampleGroup` nested in it.
    # The *sample_values* will be given to all of the examples (and groups) nested in this group.
    def build(sample_values : Internals::SampleValues) : RootExampleGroup
      RootExampleGroup.new(hooks, conditions).tap do |group|
        # Set the group's children to built versions of the children from this instance.
        group.children = @children.map do |child|
          # Build the child and up-cast to prevent type errors.
          child.build(group, sample_values).as(ExampleComponent)
        end
      end
    end
  end
end
