module Spectator
  # Base class for all example filters.
  # Checks whether an example should be run.
  # Sub-classes must implement the `#includes?` method.
  abstract class ExampleFilter
    # Checks if an example is in the filter, and should be run.
    abstract def includes?(example : Example) : Bool
  end
end
