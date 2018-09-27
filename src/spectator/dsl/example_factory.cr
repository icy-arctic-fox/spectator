module Spectator::DSL
  class ExampleFactory
    def initialize(@example_type : Example.class)
    end

    def build(group : ExampleGroup, sample_values : Internals::SampleValues) : Example
      @example_type.new(group, sample_values)
    end
  end
end
