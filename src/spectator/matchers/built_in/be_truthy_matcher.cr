module Spectator::Matchers::BuiltIn
  struct BeTruthyMatcher
    def matches?(actual_value) : Bool
      !!actual_value
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be truthy"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be falsy"
    end
  end
end
