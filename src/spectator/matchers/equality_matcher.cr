require "./matcher"

def eq(expected : T) forall T
  Spectator::Matchers::EqualityMatcher(T).new(expected)
end

module Spectator
  module Matchers
    class EqualityMatcher(T) < Matcher
      def initialize(@expected : T)
      end

      def match?(expectation : Expectation)
        expectation.actual == @expected
      end
    end
  end
end
