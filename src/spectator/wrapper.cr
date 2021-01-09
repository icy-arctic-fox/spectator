module Spectator
  # Typeless wrapper for a value.
  # Stores any value or reference type.
  # However, the type must be known when retrieving the value.
  struct Wrapper
    @value : TypelessValue

    # Creates a wrapper for the specified value.
    def initialize(value)
      @value = Value.new(value)
    end

    # Retrieves the previously wrapped value.
    # The *type* of the wrapped value must match otherwise an error will be raised.
    def get(type : T.class) : T forall T
      value = @value.as(Value(T))
      value.get
    end

    # Base type that generic types inherit from.
    # This provides a common base type,
    # since Crystal doesn't support storing an `Object` (yet).
    # Instances of this type must be downcast to `Value` to be useful.
    private abstract class TypelessValue
    end

    # Generic value wrapper.
    # Simply holds a value and inherits from `TypelessValue`,
    # so that all types of this class can be stored as one.
    private class Value(T) < TypelessValue
      # Creates the wrapper with the specified value.
      def initialize(@value : T)
      end

      # Retrieves the wrapped value.
      def get : T
        @value
      end
    end
  end
end
