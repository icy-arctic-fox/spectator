require "./error"
require "./core/location_range"

module Spectator
  # Error raised when an assertion fails.
  # This typically occurs when a matcher isn't satisfied and it's expectation isn't met.
  class AssertionFailed < Error
    getter location : Core::LocationRange?

    def initialize(message : String, @location : Core::LocationRange? = nil)
      super(message)
    end
  end
end
