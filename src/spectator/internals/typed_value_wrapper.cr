require "./value_wrapper"

module Spectator::Internals
  # Implementation of a value wrapper for a specific type.
  # Instances of this class should be created to wrap values.
  # Then the wrapper should be stored as a `ValueWrapper`
  # so that the type is deferred to runtime.
  # This trick allows the DSL to store values without explicitly knowing their type.
  class TypedValueWrapper(T) < ValueWrapper
    # Wrapped value.
    getter value : T

    # Creates a new wrapper for a value.
    def initialize(@value : T)
    end
  end
end
