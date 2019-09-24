module Spectator
  # Filter that matches examples based on their name.
  class NameExampleFilter < ExampleFilter
    # Creates the example filter.
    def initialize(@name : String)
    end

    # Checks whether the example satisfies the filter.
    def includes?(example) : Bool
      @name == example.to_s
    end
  end
end
