module Spectator
  abstract class ExampleResult
    getter example : Example
    getter elapsed : Time::Span

    abstract def passed? : Bool

    protected def initialize(@example, @elapsed)
    end
  end
end
