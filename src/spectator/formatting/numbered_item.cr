module Spectator::Formatting
  # Produces a stringified value with a numerical prefix.
  private struct NumberedItem(T)
    # Creates the numbered item.
    def initialize(@number : Int32, @text : T)
    end

    # Appends the numbered item to the output.
    def to_s(io)
      io << @number
      io << ')'
      io << ' '
      io << @text
    end
  end
end
