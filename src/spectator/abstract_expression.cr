require "./label"

module Spectator
  # Represents an expression from a test.
  # This is typically captured by an `expect` macro.
  # It consists of a label and the value of the expression.
  # The label should be a string recognizable by the user,
  # or nil if one isn't available.
  # This base class is provided so that all generic sub-classes can be stored as this one type.
  # The value of the expression can be retrieved by downcasting to the expected type with `#cast`.
  abstract class AbstractExpression
    # User recognizable string for the expression.
    # This can be something like a variable name or a snippet of Crystal code.
    getter label : Label

    # Creates the expression.
    # The *label* is usually the Crystal code evaluating to the `#value`.
    # It can be nil if it isn't available.
    def initialize(@label : Label)
    end

    # Retrieves the real value of the expression.
    abstract def value

    # Attempts to cast `#value` to the type *T* and return it.
    def cast(type : T.class) : T forall T
      value.as(T)
    end

    # Produces a string representation of the expression.
    # This consists of the label (if one is available) and the value.
    def to_s(io)
      if (label = @label)
        io << label
        io << ':'
        io << ' '
      end
      io << value
    end

    # Produces a detailed string representation of the expression.
    # This consists of the label (if one is available) and the value.
    def inspect(io)
      if (label = @label)
        io << @label
        io << ':'
        io << ' '
      end
      value.inspect(io)
    end
  end
end
