require "./result"

module Spectator
  class FailedResult < Result
    getter error : Exception

    def passed? : Bool
      false
    end

    def initialize(example, elapsed, @error)
      super(example, elapsed)
    end
  end
end
