module Spectator
  # Checks examples to determine which should be run.
  class ExampleFilter
    # The criteria for filtering examples can be multiple types.
    # A `String` will exact-match an example's name.
    # A `Regex` will perform a regular expression match on the example's name.
    # A `Source` will check if the example is in the specified file on a given line.
    # An `Int32` will check if an example is on a given line.
    alias Type = String | Regex | Source | Int32

    # Creates the example filter.
    # The *criteria* should be a list of what to filter on.
    def initialize(@criteria = [] of Type)
    end

    # Checks if an example is in the filter, and should be run.
    def includes?(example)
      return true if @criteria.empty?
      @criteria.any? do |criterion|
        example === criterion
      end
    end
  end
end
