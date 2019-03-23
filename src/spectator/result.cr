module Spectator
  # Base class that represents the outcome of running an example.
  # Sub-classes contain additional information specific to the type of result.
  abstract class Result
    # Example that was run that this result is for.
    getter example : Example

    # Constructs the base of the result.
    # The *example* should refer to the example that was run
    # and that this result is for.
    def initialize(@example)
    end

    # Calls the corresponding method for the type of result.
    # This is used to avoid placing if or case-statements everywhere based on type.
    # Each sub-class implements this method by calling the correct method on *interface*.
    abstract def call(interface)

    # Calls the corresponding method for the type of result.
    # This is used to avoid placing if or case-statements everywhere based on type.
    # Each sub-class implements this method by calling the correct method on *interface*.
    # This variation takes a block, which is passed the result.
    # The value returned from the block will be returned by this method.
    abstract def call(interface, &block : Result -> _)

    # Creates a JSON object from the result information.
    def to_json(json : ::JSON::Builder)
      json.object do
        add_json_fields(json)
      end
    end

    # Adds the common fields for a result to a JSON builder.
    private def add_json_fields(json : ::JSON::Builder)
      json.field("name", example)
      json.field("location", example.source)
      json.field("result", to_s)
    end
  end
end
