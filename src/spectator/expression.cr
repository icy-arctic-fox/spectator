require "./abstract_expression"
require "./label"

module Spectator
  # Represents an expression from a test.
  # This is typically captured by an `expect` macro.
  # It consists of a label and the value of the expression.
  # The label should be a string recognizable by the user,
  # or nil if one isn't available.
  class Expression(T) < AbstractExpression
    # Raw value of the expression.
    getter value

    # Creates the expression.
    # Expects the *value* of the expression and a *label* describing it.
    # The *label* is usually the Crystal code evaluating to the *value*.
    # It can be nil if it isn't available.
    def initialize(@value : T, label : Label)
      super(label)
    end
  end
end