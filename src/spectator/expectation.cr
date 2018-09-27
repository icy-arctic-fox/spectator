require "./matchers/matcher"

module Spectator
  class Expectation(T)
    getter actual : T

    protected def label : String
      @label.empty? ? @actual.to_s : @label
    end

    protected def initialize(@label : String, @actual : T)
    end

    def to(matcher : Matchers::Matcher)
      unless matcher.match?(self)
        raise ExpectationFailed.new(matcher.message(self))
      end
    end

    def to_not(matcher : Matchers::Matcher)
      if matcher.match?(self)
        raise ExpectationFailed.new(matcher.negated_message(self))
      end
    end

    @[AlwaysInline]
    def not_to(matcher : Matchers::Matcher)
      to_not(matcher)
    end
  end
end
