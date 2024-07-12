require "../matcher"

module Spectator::Matchers::BuiltIn
  struct BeAMatcher(T) < Matcher
    def matches?(actual_value) : Bool
      actual_value.is_a?(T)
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be a #{T}"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be a #{T}"
    end
  end
end
