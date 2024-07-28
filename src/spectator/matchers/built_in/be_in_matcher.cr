module Spectator::Matchers::BuiltIn
  struct BeInMatcher(T)
    def initialize(@expected_value : T)
    end

    def matches?(actual_value)
      actual_value.in?(@expected_value)
    end

    def failure_message(actual_value)
      <<-MESSAGE
      Expected: #{actual_value.pretty_inspect}
      to be in: #{@expected_value.pretty_inspect}
      MESSAGE
    end

    def negated_failure_message(actual_value)
      <<-MESSAGE
          Expected: #{actual_value.pretty_inspect}
      not to be in: #{@expected_value.pretty_inspect}
      MESSAGE
    end
  end
end
