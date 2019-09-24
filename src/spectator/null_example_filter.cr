module Spectator
  # Filter that matches all examples.
  class NullExampleFilter < ExampleFilter
    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      true
    end
  end
end
