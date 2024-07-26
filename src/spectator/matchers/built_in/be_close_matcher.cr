module Spectator::Matchers::BuiltIn
  struct BeCloseMatcher(T, D)
    def initialize(@expected_value : T, @delta : D)
    end

    def matches?(actual_value) : Bool
      actual_value <= @expected_value + @delta &&
        actual_value >= @expected_value - @delta
    end

    def failure_message(actual_value) : String
      <<-MESSAGE
          Expected: #{actual_value.pretty_inspect}
      to be within: #{@expected_value.pretty_inspect} ± #{@delta.pretty_inspect}
      MESSAGE
    end

    def negated_failure_message(actual_value) : String
      <<-MESSAGE
           Expected: #{actual_value.pretty_inspect}
      to be outside: #{@expected_value.pretty_inspect} ± #{@delta.pretty_inspect}
      MESSAGE
    end
  end
end
