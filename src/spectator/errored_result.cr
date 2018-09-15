require "./failed_result"

module Spectator
  class ErroredResult < FailedResult
    getter error : Exception

    def errored? : Bool
      true
    end
  end
end
