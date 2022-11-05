require "colorize"

module Spectator::Formatting::Components
  # Object that can be stringified pre-pended with a comment mark (#).
  struct Comment(T)
    # Default color for a comment.
    private COLOR = :cyan

    # Creates a comment with the specified content.
    def initialize(@content : T)
    end

    # Creates a colored comment.
    def self.colorize(content)
      new(content).colorize(COLOR)
    end

    # Writes the comment to the output.
    def to_s(io : IO) : Nil
      io << "# " << @content
    end
  end
end
