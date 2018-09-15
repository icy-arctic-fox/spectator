require "./failed_result"

module Spectator
  class ErroredResult < FailedResult
    getter error : Exception

    def errored?
      true
    end
  end
end
