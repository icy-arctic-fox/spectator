require "./test_expression"

module Spectator
  # Captures an block from a test and its label.
  struct TestBlock(ReturnType) < TestExpression(ReturnType)
    # Calls the block and retrieves the value.
    def value : ReturnType
      @proc.call
    end

    # Creates the block expression with a custom label.
    # Typically the label is the code in the block/proc.
    def initialize(@proc : -> ReturnType, label : String)
      super(label)
    end

    def self.create(proc : -> T, label : String) forall T
      {% if T.id == "ReturnType".id %}
        wrapper = ->{ proc.call; nil }
        TestBlock(Nil).new(wrapper, label)
      {% else %}
        TestBlock(T).new(proc, label)
      {% end %}
    end

    # Creates the block expression with a generic label.
    # This is used for the "should" syntax and when the label doesn't matter.
    def initialize(@proc : -> ReturnType)
      super("<Proc>")
    end

    def self.create(proc : -> T) forall T
      {% if T.id == "ReturnType".id %}
        wrapper = ->{ proc.call; nil }
        TestBlock(Nil).new(wrapper)
      {% else %}
        TestBlock(T).new(proc)
      {% end %}
    end

    # Reports complete information about the expression.
    def inspect(io)
      io << label
      io << " -> "
      io << value
    end
  end
end
