module Spectator
  # Abstract base for all examples and collections of examples.
  # This is used as the base node type for the composite design pattern.
  abstract class ExampleComponent
    # Text that describes the context or test.
    abstract def what : String

    # Indicates whether the example (or group) has been completely run.
    abstract def finished? : Bool
  end
end
