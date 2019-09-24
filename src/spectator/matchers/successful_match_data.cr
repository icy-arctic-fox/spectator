require "./match_data"

module Spectator::Matchers
  # Information about a successful match.
  struct SuccessfulMatchData < MatchData
    # Indicates that the match succeeded.
    def matched? : Bool
      true
    end
  end
end
