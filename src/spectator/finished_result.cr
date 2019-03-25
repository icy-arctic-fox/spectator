module Spectator
  # Abstract class for all results by examples
  abstract class FinishedResult < Result
    # Length of time it took to run the example.
    getter elapsed : Time::Span

    # The expectations that were run in the example.
    getter expectations : Expectations::ExampleExpectations

    # Creates a successful result.
    # The *example* should refer to the example that was run
    # and that this result is for.
    # The *elapsed* argument is the length of time it took to run the example.
    # The *expectations* references the expectations that were checked in the example.
    def initialize(example, @elapsed, @expectations)
      super(example)
    end

    # Adds the common JSON fields for all result types
    # and fields specific to finished results.
    private def add_json_fields(json : ::JSON::Builder)
      super
      json.field("time", elapsed.total_seconds)
      json.field("expectations", expectations)
    end
  end
end
