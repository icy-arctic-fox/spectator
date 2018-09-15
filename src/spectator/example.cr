module Spectator
  abstract class Example
    getter group : ExampleGroup
    getter? finished = false

    def initialize(@group)
    end

    abstract def run : Result
    abstract def description : String
  end
end
