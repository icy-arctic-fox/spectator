module Spectator
  # Define the file and line number something originated from.
  struct Source
    # Absolute file path.
    getter file : String

    # Line number in the file.
    getter line : Int32

    # Creates the source.
    def initialize(@file, @line)
    end

    # String representation of the source.
    # This is formatted as `FILE:LINE`.
    def to_s(io)
      io << file
      io << ':'
      io << line
    end
  end
end
