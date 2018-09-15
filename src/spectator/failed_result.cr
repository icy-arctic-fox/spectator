require "./result"

module Spectator
  class FailedResult < Result
    getter error : Exception

    def passed?
      false
    end

    def failed?
      true
    end

    def errored?
      false
    end

    def pending?
      false
    end

    def initialize(example, elapsed, @error)
      super(example, elapsed)
    end
  end
end
