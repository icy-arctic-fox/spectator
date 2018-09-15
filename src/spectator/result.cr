module Spectator
  abstract class Result
    getter example : Example
    getter elapsed : Time::Span

    abstract def passed? : Bool

    protected def initialize(@example, @elapsed)
    end
  end
end
