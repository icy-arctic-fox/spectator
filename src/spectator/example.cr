module Spectator
  abstract class Example
    getter? finished = false

    abstract def run : Result
    abstract def description : String
    abstract def group : ExampleGroup

    def initialize(@locals = {} of Symbol => ValueWrapper)
    end

    private getter locals
  end
end
