require "../matcher"

module Spectator::Matchers::BuiltIn
  struct AllMatcher(T) < Matcher
    def initialize(@matcher : T)
    end

    def matches?(actual_value) : Bool
      actual_value.each do |value|
        return false unless apply_matcher(value)
      end
      true
    end

    def does_not_match?(actual_value) : Bool
      actual_value.each do |value|
        return false if apply_negated_matcher(value)
      end
      true
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to match #{@matcher}"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to match #{@matcher}"
    end

    private def apply_matcher(value) : Bool
      matcher = @matcher
      if matcher.responds_to?(:matches?)
        matcher.matches?(value)
      else
        matcher === value
      end
    end

    private def apply_negated_matcher(value) : Bool
      matcher = @matcher
      if matcher.responds_to?(:does_not_match?)
        matcher.does_not_match?(value)
      elsif matcher.responds_to?(:matches?)
        !matcher.matches?(value)
      else
        !(matcher === value)
      end
    end
  end
end
