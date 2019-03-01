module Spectator::Formatting
  # Produces a stringified comment for output.
  private struct Comment(T)
    # Creates the comment.
    def initialize(@text : T)
    end

    # Appends the comment to the output.
    def to_s(io)
      io << '#'
      io << ' '
      io << @text
    end

    # Creates a colorized version of the comment.
    def self.color(text : T) forall T
      Color.comment(new(text))
    end
  end
end
