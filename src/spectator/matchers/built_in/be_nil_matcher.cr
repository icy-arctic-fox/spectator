module Spectator::Matchers::BuiltIn
  struct BeNilMatcher
    def matches?(actual_value)
      actual_value.nil?
    end

    def failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} to be nil"
    end

    def negated_failure_message(actual_value)
      "Expected #{actual_value.pretty_inspect} not to be nil"
    end
  end
end
