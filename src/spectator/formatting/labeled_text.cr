module Spectator::Formatting
  # Produces a stringified message with a prefix.
  private struct LabeledText(T)
    # Creates the labeled text.
    def initialize(@label : String, @text : T)
    end

    # Appends the message to the output.
    def to_s(io)
      io << @label
      io << ": "
      io << @text
    end
  end
end
