require "../double"

module Spectator::DSL
  # Creates instances of doubles from a specified type.
  class DoubleFactory
    # Creates the factory.
    # The type passed to this constructor must be a double.
    def initialize(@double_type : Double.class)
    end

    # Constructs a new double instance and returns it.
    # The *sample_values* are passed to `Double#initialize`.
    def build(sample_values : Internals::SampleValues) : Double
      @double_type.new
    end
  end
end
