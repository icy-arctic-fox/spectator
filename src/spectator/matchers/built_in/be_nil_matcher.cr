require "../matcher"

module Spectator::Matchers::BuiltIn
  struct BeNilMatcher < Matcher
    def matches?(actual_value) : Bool
      actual_value.nil?
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be nil"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be nil"
    end
  end
end
