require "./labeled_value"
require "./match_data"

module Spectator::Matchers
  struct FailedMatchData < MatchData
    def matched?
      false
    end

    getter failure_message : String

    getter values : Array(LabeledValue)

    def initialize(@failure_message, @values = [] of LabeledValue)
    end
  end
end
