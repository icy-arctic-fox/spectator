module Spectator::Core
  # Information about a location in the source code.
  struct Location
    # Name of the source file.
    getter file : String

    # Line number in the source file.
    getter! line : Int32

    # Creates a new location.
    def initialize(@file, @line = nil)
    end

    def self.here(offset = 0, *, file = __FILE__, line = __LINE__) : self
      new(file, line + offset)
    end

    # Parses a string into a location.
    def self.parse(string : String) : self
      # Avoid issues on Windows with colons in filenames (drive letters).
      colon_index = string.rindex(':')
      return new(string) unless colon_index
      file = string[0...colon_index]
      line = string[colon_index + 1, string.size - colon_index - 1].to_i?
      # Use the whole string if the line number can't be parsed.
      # This likely means it is a Windows path with a colon and no line number.
      line ? new(file, line) : new(string)
    end

    def relative_to(path : String | Path) : Location
      relative_path = Path[file].relative_to(path)
      Location.new(relative_path.to_s, line)
    end

    # Constructs a string representation of the location.
    def to_s(io : IO) : Nil
      io << @file
      if line = @line
        io << ':' << line
      end
    end
  end
end
