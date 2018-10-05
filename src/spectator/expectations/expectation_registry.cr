module Spectator::Expectations
  # Tracks the expectations and their outcomes in an example.
  # A single instance of this class should be associated with one example.
  class ExpectationRegistry
    private getter? raise_on_failure : Bool

    private def initialize(@raise_on_failure = true)
    end

    def report(result : Expectation::Result) : Nil
      raise NotImplementedError.new("ExpectationRegistry#report")
    end

    def self.current : ExpectationRegistry
      raise NotImplementedError.new("ExpectationRegistry.current")
    end

    def self.start(example : Example) : Nil
      raise NotImplementedError.new("ExpectationRegistry.start")
    end

    def self.finish : ExpectationResults
      raise NotImplementedError.new("ExpectationRegistry.finish")
    end
  end
end
