module Spectator::Formatting
  # Text displayed when fail-fast is enabled and tests were skipped.
  private struct RemainingText
    # Creates the text object.
    def initialize(@count : Int32)
    end

    # Appends the command to the output.
    def to_s(io)
      io << "Text execution aborted (fail-fast) - "
      io << @count
      io << " examples were omitted."
    end
  end
end
