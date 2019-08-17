require "./nested_example_group_builder"

module Spectator::DSL
  # Specialized example group builder for "sample" groups.
  # The type parameter `C` is the type to instantiate to create the collection.
  # The type parameter `T` should be the type of each element in the sample collection.
  # This builder creates a container group with groups inside for each item in the collection.
  # The hooks are only defined for the container group.
  # By doing so, the hooks are defined once, are inherited, and use less memory.
  class SampleExampleGroupBuilder(C, T) < NestedExampleGroupBuilder
    # Creates a new group builder.
    # The value for *what* should be the text the user specified for the collection.
    # The *collection_type* is the type to create that will produce the items.
    # The *collection_builder* is a proc that takes an instance of *collection_type*
    # and returns an actual array of items to create examples for.
    # The *name* is the variable name that the user accesses the current collection item with.
    #
    # In this code:
    # ```
    # sample random_integers do |integer|
    #   # ...
    # end
    # ```
    # The *what* would be "random_integers"
    # and the collection would contain the items returned by calling *random_integers*.
    # The *name* would be "integer".
    #
    # The *symbol* is passed along to the sample values
    # so that the example code can retrieve the current item from the collection.
    # The symbol should be unique.
    def initialize(what : String, @collection_type : C.class, @collection_builder : C -> Array(T),
                   @name : String, @symbol : Symbol)
      super(what)
    end

    # Builds the example group.
    # A new `NestedExampleGroup` will be returned
    # which can have instances of `Example` and `ExampleGroup` nested in it.
    # The *parent* should be the group that contains this group.
    # The *sample_values* will be given to all of the examples (and groups) nested in this group.
    def build(parent : ExampleGroup, sample_values : Internals::SampleValues) : NestedExampleGroup
      collection = @collection_builder.call(@collection_type.new(sample_values))

      # This creates the container for the sub-groups.
      # The hooks are defined here, instead of repeating for each sub-group.
      NestedExampleGroup.new(@what, parent, hooks, conditions).tap do |group|
        # Set the container group's children to be sub-groups for each item in the collection.
        group.children = collection.map do |value|
          # Create a sub-group for each item in the collection.
          build_sub_group(group, sample_values, value).as(ExampleComponent)
        end
      end
    end

    # Builds a sub-group for one item in the collection.
    # The *parent* should be the container group currently being built by the `#build` call.
    # The *sample_values* should be the same as what was passed to the `#build` call.
    # The *value* is the current item in the collection.
    # The value will be added to the sample values for the sub-group,
    # so it shouldn't be added prior to calling this method.
    private def build_sub_group(parent : ExampleGroup, sample_values : Internals::SampleValues, value : T) : NestedExampleGroup
      # Add the value to sample values for this sub-group.
      sub_values = sample_values.add(@symbol, @name, value)
      NestedExampleGroup.new(value.to_s, parent, ExampleHooks.empty, ExampleConditions.empty).tap do |group|
        # Set the sub-group's children to built versions of the children from this instance.
        group.children = @children.map do |child|
          # Build the child and up-cast to prevent type errors.
          child.build(group, sub_values).as(ExampleComponent)
        end
      end
    end
  end
end
