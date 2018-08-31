require "./example_result"

module Spectator
  class FailedExampleResult < ExampleResult
    def passed? : Bool
      false
    end
  end
end
