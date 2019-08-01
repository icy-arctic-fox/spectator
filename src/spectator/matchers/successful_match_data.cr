require "./match_data"

module Spectator::Matchers
  struct SuccessfulMatchData < MatchData
    def matched?
      true
    end
  end
end
