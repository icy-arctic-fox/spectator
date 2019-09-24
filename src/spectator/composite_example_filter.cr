module Spectator
  # Filter that combines multiple other filters.
  class CompositeExampleFilter < ExampleFilter
    # Creates the example filter.
    def initialize(@filters : Array(ExampleFilter))
    end

    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      @filters.any?(&.includes?(example))
    end
  end
end
