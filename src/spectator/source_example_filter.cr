module Spectator
  # Filter that matches examples in a given file and line.
  class SourceExampleFilter < ExampleFilter
    # Creates the filter.
    # The *source* indicates which file and line the example must be on.
    def initialize(@source : Source)
    end

    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      @source === example.source
    end
  end
end
