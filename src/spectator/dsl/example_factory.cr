module Spectator::DSL
  # Creates instances of examples from a specified class.
  class ExampleFactory
    # Creates the factory.
    # The type passed to this constructor must be a sub-type of `Example`.
    def initialize(@example_type : Example.class)
    end

    # Constructs a new example instance and returns it.
    # The *group* and *sample_values* are passed to `Example#initialize`.
    def build(group : ExampleGroup, sample_values : Internals::SampleValues) : Example
      @example_type.new(group, sample_values)
    end
  end
end
