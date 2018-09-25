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
    end
  end
end
