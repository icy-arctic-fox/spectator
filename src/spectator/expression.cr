require "./abstract_expression"

module Spectator
  # Represents an expression from a test.
  # This is typically captured by an `expect` macro.
  # It consists of a label and a typed expression.
  # The label should be a string recognizable by the user,
  # or nil if one isn't available.
  abstract class Expression(T) < AbstractExpression
    # Retrieves the underlying value of the expression.
    abstract def value : T

    # Retrieves the evaluated value of the expression.
    def raw_value
      value
    end
  end
end
