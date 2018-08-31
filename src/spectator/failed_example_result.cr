require "./example_result"

module Spectator
  class FailedExampleResult < ExampleResult
    getter error : Exception

    def passed? : Bool
      false
    end

    def initialize(@example, @error)
    end
  end
end
