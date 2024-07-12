require "../matcher"

module Spectator::Matchers::BuiltIn
  struct BeOneOfMatcher(T) < Matcher
    def initialize(@expected : T)
      {% raise "Expected type must be a Tuple" unless T < Tuple %}
    end

    def matches?(actual_value) : Bool
      @expected.includes?(actual_value)
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to be one of #{@expected.pretty_inspect}"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to be one of #{@expected.pretty_inspect}"
    end
  end
end
