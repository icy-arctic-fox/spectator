module Spectator
  abstract class Result
    getter example : Example
    getter elapsed : Time::Span

    abstract def passed? : Bool
    abstract def failed? : Bool
    abstract def errored? : Bool
    abstract def pending? : Bool

    protected def initialize(@example, @elapsed)
    end
  end
end
