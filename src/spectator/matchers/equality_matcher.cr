require "./matcher"

module Spectator
  module Matchers
    class EqualityMatcher(T) < Matcher
      def initialize(label, @expected : T)
        super(label)
      end

      def match?(expectation : Expectation)
        expectation.actual == @expected
      end

      def message(expectation : Expectation) : String
        "Expected #{expectation.actual} to equal #{@expected} (using ==)"
      end

      def negated_message(expectation : Expectation) : String
        "Expected #{expectation.actual} to not equal #{@expected} (using ==)"
      end
    end
  end
end
