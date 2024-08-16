require "./error"
require "./core/location_range"

module Spectator
  class ExampleSkipped < Error
    getter location : Core::LocationRange?

    def initialize(message : String? = nil, @location : Core::LocationRange? = nil)
      super(message)
    end
  end
end
