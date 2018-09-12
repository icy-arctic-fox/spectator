require "./source"

module Spectator
  abstract class Example
    getter context : Context

    def initialize(@context)
    end

    abstract def run : Nil
    abstract def description : String
  end
end
