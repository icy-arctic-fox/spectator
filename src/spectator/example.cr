module Spectator
  abstract class Example
    getter? finished = false
    getter group : ExampleGroup

    abstract def run : Result
    abstract def description : String

    def initialize(@group, @locals = {} of Symbol => Internals::ValueWrapper)
    end

    private getter locals
  end
end
