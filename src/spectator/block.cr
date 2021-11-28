require "./expression"
require "./label"

module Spectator
  # Represents a block from a test.
  # This is typically captured by an `expect` macro.
  # It consists of a label and parameter-less block.
  # The label should be a string recognizable by the user,
  # or nil if one isn't available.
  class Block(T) < Expression(T)
    # Creates the block expression from a proc.
    # The *proc* will be called to evaluate the value of the expression.
    # The *label* is usually the Crystal code for the *proc*.
    # It can be nil if it isn't available.
    def initialize(@block : -> T, label : Label = nil)
      super(label)
    end

    # Creates the block expression by capturing a block as a proc.
    # The block will be called to evaluate the value of the expression.
    # The *label* is usually the Crystal code for the *block*.
    # It can be nil if it isn't available.
    def initialize(label : Label = nil, &@block : -> T)
      super(label)
    end

    # Evaluates the block and returns the value from it.
    # This method _does not_ cache the resulting value like `#value` does.
    # Successive calls to this method may return different values.
    def value : T
      @block.call
    end
  end
end
