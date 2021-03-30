module Spectator
  # Filter that matches examples on a given line.
  class LineExampleFilter < ExampleFilter
    # Creates the example filter.
    def initialize(@line : Int32)
    end

    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      source = example.source
      # end_line is present so there is a range to check against
      if end_line = source.end_line
        (source.line..end_line).covers?(@line)
      else
        source.line == @line
      end
    end
  end
end
