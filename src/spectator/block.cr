require "./expression"
require "./label"
require "./lazy"

module Spectator
  # Represents a block from a test.
  # This is typically captured by an `expect` macro.
  # It consists of a label and parameterless block.
  # The label should be a string recognizable by the user,
  # or nil if one isn't available.
  class Block(T) < Expression(T)
    # Cached value returned from the block.
    @value = Lazy(T).new

    # Creates the block expression from a proc.
    # The *proc* will be called to evaluate the value of the expression.
    # The *label* is usually the Crystal code for the *proc*.
    # It can be nil if it isn't available.
    def initialize(@block : -> T, label : Label)
      super(label)
    end

    # Creates the block expression by capturing a block as a proc.
    # The block will be called to evaluate the value of the expression.
    # The *label* is usually the Crystal code for the *block*.
    # It can be nil if it isn't available.
    def initialize(label : Label, &@block : -> T)
      super(label)
    end

    # Retrieves the value of the block expression.
    # This will be the return value of the block.
    # The block is lazily evaluated and the value retrieved only once.
    # Afterwards, the value is cached and returned by successive calls to this method.
    def value
      @value.get { call }
    end

    # Evaluates the block and returns the value from it.
    # This method _does not_ cache the resulting value like `#value` does.
    # Successive calls to this method may return different values.
    def call : T
      @block.call
    end
  end
end
