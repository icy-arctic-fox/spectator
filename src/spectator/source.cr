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

    # Parses a source from a string.
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

    # String representation of the source.
    # This is formatted as:
    # ```text
    # FILE:LINE
    # ```
    def to_s(io)
      io << path
      io << ':'
      io << line
    end

    # Creates the JSON representation of the source.
    def to_json(json : ::JSON::Builder)
      json.string(to_s)
    end
  end
end
