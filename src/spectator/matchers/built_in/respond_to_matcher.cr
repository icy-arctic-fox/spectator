require "../matcher"

module Spectator::Matchers::BuiltIn
  struct RespondToMatcher(NT) < Matcher
    def matches?(actual_value) : Bool
      {% begin %}
        actual_value.responds_to?({{NT.keys.first.symbolize}})
      {% end %}
    end

    def failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} to respond to #{method_name}"
    end

    def negative_failure_message(actual_value) : String
      "Expected #{actual_value.pretty_inspect} not to respond to #{method_name}"
    end

    private def method_name : Symbol
      {{NT.keys.first.symbolize}}
    end
  end
end
