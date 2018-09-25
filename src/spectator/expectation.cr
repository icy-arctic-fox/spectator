require "./matchers/matcher"

module Spectator
  class Expectation(T)
    private getter label : String
    getter actual : T

    protected def initialize(@label : String, @actual : T)
    end

    def to(matcher : Matchers::Matcher)
      unless matcher.match?(self)
        raise ExpectationFailed.new
      end
    end

    def to_not(matcher : Matchers::Matcher)
      if matcher.match?(self)
        raise ExpectationFailed.new
      end
    end

    @[AlwaysInline]
    def not_to(matcher : Matchers::Matcher)
      to_not(matcher)
    end
  end
end
