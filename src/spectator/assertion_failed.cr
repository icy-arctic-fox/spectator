require "./error"
require "./core/location_range"
require "./matchers/match_data"

module Spectator
  # Error raised when an assertion fails.
  # This typically occurs when a matcher isn't satisfied and it's expectation isn't met.
  class AssertionFailed < Error
    getter match_data : Matchers::MatchData?

    getter message : String? do
      @match_data.try &.to_s
    end

    getter location : Core::LocationRange? do
      @match_data.try &.location
    end

    def initialize(@match_data : Matchers::MatchData)
      super(nil)
    end

    def initialize(message : String? = nil, @location : Core::LocationRange? = nil)
      super(message)
    end
  end
end
