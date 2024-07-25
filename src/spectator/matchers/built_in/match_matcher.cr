module Spectator::Matchers::BuiltIn
  struct MatchMatcher(T)
    def initialize(@expected_value : T)
    end

    def matches?(actual_value) : Bool
      !!(actual_value =~ @expected_value)
    end

    def failure_message(actual_value) : String
      <<-END_OF_MESSAGE
      Expected: #{actual_value.pretty_inspect}
      to match: #{@expected_value.pretty_inspect}
      END_OF_MESSAGE
    end

    def negated_failure_message(actual_value) : String
      <<-END_OF_MESSAGE
          Expected: #{actual_value.pretty_inspect}
      not to match: #{@expected_value.pretty_inspect}
      END_OF_MESSAGE
    end
  end
end
