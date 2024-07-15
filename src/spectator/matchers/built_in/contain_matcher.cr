module Spectator::Matchers::BuiltIn
  struct ContainMatcher(T)
    def initialize(@expected : T)
      {% raise "Expected type must be a Tuple" unless T < Tuple %}
    end

    def matches?(actual_value) : Bool
      @expected.all? { |item| actual_value.includes?(item) }
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to contain #{@expected.pretty_inspect}"
    end

    def negated_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to contain #{@expected.pretty_inspect}"
    end
  end
end
