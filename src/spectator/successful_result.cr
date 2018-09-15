require "./result"

module Spectator
  class SuccessfulResult < Result
    def passed? : Bool
      true
    end
  end
end
