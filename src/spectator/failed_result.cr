require "./result"

module Spectator
  class FailedResult < Result
    getter error : Exception
    getter expectations : Expectations::ExpectationResults

    def initialize(example, elapsed, @expectations, @error)
      super(example, elapsed)
    end

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
  end
end
