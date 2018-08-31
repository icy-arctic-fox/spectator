require "./example_result"

module Spectator
  class SuccessfulExampleResult < ExampleResult
    def passed? : Bool
      true
    end
  end
end
