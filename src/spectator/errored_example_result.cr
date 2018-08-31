require "./failed_example_result"

module Spectator
  class ErroredExampleResult < FailedExampleResult
    getter error : Exception

    def errored? : Bool
      true
    end

    def initialize(@example, @error)
    end
  end
end
