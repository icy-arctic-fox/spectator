require "./location"

module Spectator::Core
  # Information about a range in the source code.
  struct LocationRange
    # Name of the source file.
    getter file : String

    # Starting line number in the source file.
    getter line : Int32

    # Ending line number in the source file.
    getter end_line : Int32

    # Creates a new location range.
    def initialize(@file, @line, @end_line)
    end

    # Creates a new location range with the same start and end line.
    def initialize(@file, @line)
      @end_line = @line
    end

    def self.here(offset = 0, *,
                  file = __FILE__,
                  line = __LINE__,
                  end_line = __END_LINE__) : self
      new(file, line + offset, end_line + offset)
    end

    # Checks if the location is in the range.
    def includes?(location : Location)
      return false if location.file != @file
      return true unless line = location.line?
      @line <= line && line <= @end_line
    end

    def relative_to(path : String | Path) : LocationRange
      relative_path = Path[file].relative_to(path)
      LocationRange.new(relative_path.to_s, line, end_line)
    end

    # Constructs a string representation of the location range.
    def to_s(io : IO) : Nil
      io << @file << ':' << @line
      io << '-' << @end_line if @end_line != @line
    end

    # Returns true if the location is in the range.
    def ===(other : Location)
      includes?(other)
    end
  end
end
