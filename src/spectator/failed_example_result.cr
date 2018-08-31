require "./example_result"

module Spectator
  class FailedExampleResult < ExampleResult
    getter error : Exception

    def passed? : Bool
      false
    end

    def initialize(example, elapsed, @error)
      super(example, elapsed)
    end
  end
end
