require "./match_data"

module Spectator::Matchers
  # Match data that does nothing useful.
  # This is a workaround for a compilation issue - hopefully temporary.
  # This might be the same issue that `DummyExample` solves.
  # Without this, the Crystal compiler complains:
  # ```text
  # undefined method 'Spectator::Matchers::MatchData#message()'
  # ```
  # The method is clearly defined by `MatchData`, just abstract.
  # Additionally, there are implementations of `MatchData` -
  # see `NilMatcher::MatchData`.
  private struct DummyMatchData < MatchData
    # Dummy values.
    def values
      {expected: nil, actual: nil}
    end

    # Dummy message.
    def message
      "DUMMY"
    end

    # Dummy message.
    def negated_message
      "DUMMY"
    end
  end
end
