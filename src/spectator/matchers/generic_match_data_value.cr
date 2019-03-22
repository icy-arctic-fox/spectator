require "./match_data_value"

module Spectator::Matchers
  # Wraps a value for used in match data.
  private class GenericMatchDataValue(T) < MatchDataValue
    # Creates the wrapper.
    def initialize(@value : T)
    end

    # Stringifies the value.
    def to_s(io)
      @value.inspect(io)
    end
  end
end
