require "./matchers/matcher"

def expect(actual : T) forall T
  Spectator::Expectation.new(actual)
end

module Spectator
  class Expectation(T)
    getter actual : T

    protected def initialize(@actual : T)
    end

    def to(matcher : Matchers::Matcher)
      unless matcher.match?(self)
        raise ExpectationFailedError.new
      end
    end
  end
end
