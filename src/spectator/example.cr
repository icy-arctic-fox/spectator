require "./source"

module Spectator
  abstract class Example
    getter context : Context
    getter? finished = false

    def initialize(@context)
    end

    abstract def run : ExampleResult
    abstract def description : String
  end
end
