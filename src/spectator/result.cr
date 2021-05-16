module Spectator
  # Base class that represents the outcome of running an example.
  # Sub-classes contain additional information specific to the type of result.
  abstract class Result
    # Length of time it took to run the example.
    getter elapsed : Time::Span

    # The assertions checked in the example.
    getter expectations : Enumerable(Expectation)

    # Creates the result.
    # *elapsed* is the length of time it took to run the example.
    def initialize(@elapsed, @expectations = [] of Expectation)
    end

    # Calls the corresponding method for the type of result.
    # This is the visitor design pattern.
    abstract def accept(visitor)

    # Indicates whether the example passed.
    abstract def pass? : Bool

    # Indicates whether the example failed.
    abstract def fail? : Bool

    # Indicates whether the example was skipped.
    def pending? : Bool
      !pass? && !fail?
    end

    # Creates a JSON object from the result information.
    def to_json(json : ::JSON::Builder, example)
      json.object do
        add_json_fields(json, example)
      end
    end

    # Adds the common fields for a result to a JSON builder.
    private def add_json_fields(json : ::JSON::Builder, example)
      json.field("name", example)
      json.field("location", example.location)
      json.field("result", to_s)
      json.field("time", elapsed.total_seconds)
      json.field("expectations", expectations)
    end
  end
end
