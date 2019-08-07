require "./match_data"

module Spectator::Matchers
  struct FailedMatchData < MatchData
    def matched?
      false
    end

    getter failure_message : String

    getter values : Array(Tuple(Symbol, String))

    def initialize(@failure_message, **values)
      @values = values.to_a
    end
  end
end
