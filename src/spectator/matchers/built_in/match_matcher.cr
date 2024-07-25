module Spectator::Matchers::BuiltIn
  struct MatchMatcher(T)
    def initialize(@expected_value : T)
    end

    def matches?(actual_value) : Bool
      !!(actual_value =~ @expected_value)
    end

    def failure_message(actual_value) : String
      "Expected: #{actual_value.pretty_inspect}\n" +
        "to match: #{@expected_value.pretty_inspect}"
    end

    def negated_failure_message(actual_value) : String
      "    Expected: #{actual_value.pretty_inspect}\n" +
        "not to match: #{@expected_value.pretty_inspect}"
    end
  end
end
