module Spectator
  # Filter that matches examples in a given file and line.
  class LocationExampleFilter < ExampleFilter
    # Creates the filter.
    # The *location* indicates which file and line the example must be on.
    def initialize(@location : Location)
    end

    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      @location === example.location
    end
  end
end
