require "./label"

module Spectator
  # Represents an expression from a test.
  # This is typically captured by an `expect` macro.
  # It consists of a label and the value of the expression.
  # The label should be a string recognizable by the user,
  # or nil if one isn't available.
  #
  # This base class is provided so that all generic sub-classes can be stored as this one type.
  # The value of the expression can be retrieved by down-casting to the expected type with `#cast`.
  #
  # NOTE: This is intentionally a class and not a struct.
  # If it were a struct, changes made to the value held by an instance may not be kept when passing it around.
  # See commit ca564619ad2ae45f832a058d514298c868fdf699.
  abstract class AbstractExpression
    # User recognizable string for the expression.
    # This can be something like a variable name or a snippet of Crystal code.
    getter label : Label

    # Creates the expression.
    # The *label* is usually the Crystal code evaluating to the `#raw_value`.
    # It can be nil if it isn't available.
    def initialize(@label : Label)
    end

    # Retrieves the evaluated value of the expression.
    abstract def raw_value

    # Attempts to cast `#raw_value` to the type *T* and return it.
    def cast(type : T.class) : T forall T
      raw_value.as(T)
    end

    # Produces a string representation of the expression.
    # This consists of the label (if one is available) and the value.
    def to_s(io : IO) : Nil
      if (label = @label)
        io << label << ": "
      end
      raw_value.to_s(io)
    end

    # Produces a detailed string representation of the expression.
    # This consists of the label (if one is available) and the value.
    def inspect(io : IO) : Nil
      if (label = @label)
        io << label << ": "
      end
      raw_value.inspect(io)
    end
  end
end
