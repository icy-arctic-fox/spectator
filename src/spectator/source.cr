module Spectator
  class Source
    getter file : String
    getter line : Int32

    def initialize(@file, @line)
    end

    def to_s(io)
      io << file
      io << ':'
      io << line
    end
  end
end
