require "./match_data_value"

module Spectator::Matchers
  # Selects a value based on whether the value is negated.
  # This is used when a matcher is negated.
  private class AlternativeMatchDataValue(T1, T2) < MatchDataValue
    # Creates the wrapper.
    def initialize(@value1 : T1, @value2 : T2)
      @negated = false
    end

    # Negates (toggles) the value.
    def negate
      @negated = !@negated
    end

    # Returns the correct value based on the negated status.
    def value
      @negated ? @value2 : @value1
    end

    # Produces a stringified value.
    def to_s(io)
      @value.inspect(io)
    end

    # Produces a stringified value with additional information.
    def inspect(io)
      value.inspect(io)
    end
  end
end
