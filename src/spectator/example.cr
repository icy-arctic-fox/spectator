module Spectator
  abstract class Example
    getter? finished = false
    getter group : ExampleGroup

    abstract def run : Result
    abstract def description : String

    def initialize(@group, sample_values : Internals::SampleValues)
    end

    private getter locals

    def to_s(io)
      @group.to_s(io)
      io << ' '
      io << description
    end
  end
end
