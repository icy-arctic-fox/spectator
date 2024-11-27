require "./error"
require "./core/location_range"
require "./matchers/match_failure"

module Spectator
  # Error raised when an assertion fails.
  # This typically occurs when a matcher isn't satisfied and it's expectation isn't met.
  class AssertionFailed < Error
    getter match_failure : Matchers::MatchFailure?

    getter message : String? do
      @match_failure.try &.to_s
    end

    getter location : Core::LocationRange?

    def initialize(@match_failure : Matchers::MatchFailure, @location : Core::LocationRange? = nil)
      super(nil)
    end

    def initialize(message : String? = nil, @location : Core::LocationRange? = nil)
      super(message)
    end
  end
end
