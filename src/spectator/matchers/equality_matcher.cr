require "./matcher"

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
