module Spectator::SpecHelpers
  # Information about an `expect` call in an example.
  struct Expectation
    # Indicates whether the expectation passed or failed.
    getter? satisfied : Bool

    # Message when the expectation failed.
    # Only available when `#satisfied?` is false.
    getter! message : String

    # Additional information about the expectation.
    # Only available when `#satisfied?` is false.
    getter! values : Hash(String, String)

    # Creates the expectation outcome.
    def initialize(@satisfied, @message, @values)
    end

    # Extracts the expectation information from a `JSON::Any` object.
    def self.from_json_any(object : JSON::Any)
      satisfied = object["satisfied"].as_bool
      message = object["failure"]?.try(&.as_s?)
      values = object["values"]?.try(&.as_h?)
      values = values.transform_values(&.as_s) if values
      new(satisfied, message, values)
    end
  end
end
