module Spectator
  abstract class Example
    getter? finished = false

    abstract def run : Result
    abstract def description : String
    abstract def group : ExampleGroup
  end
end
