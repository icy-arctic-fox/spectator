module Spectator::Matchers::BuiltIn
  struct BeCloseMatcher(T, D)
    def initialize(@expected_value : T, @delta : D)
    end

    def matches?(actual_value) : Bool
      actual_value <= @expected_value + @delta &&
        actual_value >= @expected_value - @delta
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be close to #{@expected_value.pretty_inspect} ± #{@delta.pretty_inspect}"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be close to #{@expected_value.pretty_inspect} ± #{@delta.pretty_inspect}"
    end
  end
end
