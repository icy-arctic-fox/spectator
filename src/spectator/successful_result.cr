require "./result"

module Spectator
  class SuccessfulResult < Result
    getter expectations : Expectations::ExampleExpectations

    def initialize(example, elapsed, @expectations)
      super(example, elapsed)
    end

    def passed?
      true
    end

    def failed?
      false
    end

    def errored?
      false
    end

    def pending?
      false
    end
  end
end
