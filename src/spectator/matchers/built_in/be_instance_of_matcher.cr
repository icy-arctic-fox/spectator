module Spectator::Matchers::BuiltIn
  struct BeInstanceOfMatcher(T)
    def matches?(actual_value) : Bool
      actual_value.class == T
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be an instance of #{T}"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be an instance of #{T}"
    end
  end
end
