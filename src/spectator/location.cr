module Spectator
  # Defines the file and line number a piece of code originated from.
  struct Location
    # Absolute file path.
    getter file : String

    # Starting line number in the file.
    getter line : Int32

    # Ending line number in the file.
    getter end_line : Int32

    # Creates the location.
    def initialize(@file, @line, end_line = nil)
      # if an end line is not provided,
      # make the end line the same as the start line
      @end_line = end_line || @line
    end

    # Parses a location from a string.
    # The *string* should be in the form:
    # ```text
    # FILE:LINE
    # ```
    # This matches the output of the `#to_s` method.
    def self.parse(string)
      # Make sure to handle multiple colons.
      # If this ran on Windows, there's a possibility of a colon in the path.
      # The last element should always be the line number.
      parts = string.split(':')
      path = parts[0...-1].join(':')
      line = parts.last
      file = File.expand_path(path)
      self.new(file, line.to_i)
    end

    # The relative path to the file from the current directory.
    # If the file isn't in the current directory or a sub-directory,
    # then the absolute path is provided.
    def path
      # Add the path separator here.
      # Otherwise, things like:
      # `spectator/foo.cr` and `spectator.cr` overlap.
      # It also makes the substring easier.
      cwd = Dir.current + File::SEPARATOR
      if file.starts_with?(cwd)
        # Relative to the current directory.
        # Trim the current directory path from the beginning.
        file[cwd.size..-1]
      else
        # Not trivial to find the file.
        # Return the absolute path.
        file
      end
    end

    # String representation of the location.
    # This is formatted as:
    # ```text
    # FILE:LINE
    # ```
    def to_s(io : IO) : Nil
      io << path << ':' << line
    end
  end
end
