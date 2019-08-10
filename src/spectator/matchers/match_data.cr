module Spectator::Matchers
  # Information about the outcome of a match.
  abstract struct MatchData
    # Indicates whether the match as successful or not.
    abstract def matched? : Bool
  end
end
