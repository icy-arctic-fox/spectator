require "../core/location"

module Spectator::Matchers
  struct Expect(T)
    def initialize(@actual : T, @location : Core::Location? = nil)
    end

    def to(matcher : Matcher)
    end

    def not_to(matcher : Matcher)
    end

    def to_not(matcher : Matcher)
      not_to(matcher)
    end
  end
end
