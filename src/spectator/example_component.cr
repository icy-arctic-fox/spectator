module Spectator
  # Abstract base for all examples and collections of examples.
  # This is used as the base node type for the composite design pattern.
  abstract class ExampleComponent
    # Text that describes the context or test.
    abstract def what : Symbol | String

    # Indicates whether the example (or group) has been completely run.
    abstract def finished? : Bool

    # The number of examples in this instance.
    abstract def example_count : Int

    # Lookup the example with the specified index.
    abstract def [](index : Int) : Example

    # Indicates that the component references a type or method.
    abstract def symbolic? : Bool
  end
end
