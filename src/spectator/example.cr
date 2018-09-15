require "./source"

module Spectator
  abstract class Example
    getter group : ExampleGroup
    getter? finished = false

    def initialize(@group)
    end

    abstract def run : ExampleResult
    abstract def description : String
  end
end
