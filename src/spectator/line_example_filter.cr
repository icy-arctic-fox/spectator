module Spectator
  # Filter that matches examples on a given line.
  class LineExampleFilter < ExampleFilter
    # Creates the example filter.
    def initialize(@line : Int32)
    end

    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      start_line = example.source.line
      end_line = example.source.end_line
      (start_line..end_line).covers?(@line)
    end
  end
end
