module Spectator
  abstract class ExampleResult
    getter example : Example

    abstract def passed? : Bool

    protected def initialize(@example)
    end
  end
end
