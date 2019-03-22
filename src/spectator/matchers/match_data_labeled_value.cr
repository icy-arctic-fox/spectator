module Spectator::Matchers
  # A value from match data with a label.
  private struct MatchDataLabeledValue
    # Label tied to the value.
    # This annotates what the value is.
    getter label : Symbol

    # The actual value from the match data.
    getter value : MatchDataValue

    # Creates a new labeled value.
    def initialize(@label, @value)
    end
  end
end
