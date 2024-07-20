require "./error"
require "./matchers/match_data"
require "./core/location_range"

module Spectator
  # Error raised when an assertion fails.
  # This typically occurs when a matcher isn't satisfied and it's expectation isn't met.
  class AssertionFailed < Error
    getter fields : Array(Matchers::MatchData::Field)
    getter location : Core::LocationRange?

    def initialize(message : String,
                   @location : Core::LocationRange? = nil,
                   @fields : Array(Matchers::MatchData::Field) = [] of Matchers::MatchDataField)
      super(message)
    end
  end
end
