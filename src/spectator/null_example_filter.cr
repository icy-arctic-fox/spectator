module Spectator
  # Filter that matches all examples.
  class NullExampleFilter < ExampleFilter
    # Checks whether the example satisfies the filter.
    def includes?(example)
      true
    end
  end
end
