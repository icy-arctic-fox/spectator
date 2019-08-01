module Spectator::Matchers
  abstract struct MatchData
    abstract def matched? : Bool
  end
end
