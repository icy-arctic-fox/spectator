require "./match_data"

module Spectator::Matchers
  # Information about a successful match.
  struct SuccessfulMatchData < MatchData
    # Indicates that the match succeeded.
    def matched?
      true
    end
  end
end
