require "./matcher"

module Spectator::Matchers
  class EqualityMatcher(T) < Matcher
    def initialize(label, @expected : T)
      super(label)
    end

    def match?(expectation : Expectation)
      expectation.actual == @expected
    end

    def message(expectation : Expectation) : String
      "Expected #{expectation.label} to equal #{label} (using ==)"
    end

    def negated_message(expectation : Expectation) : String
      "Expected #{expectation.label} to not equal #{label} (using ==)"
    end
  end
end
