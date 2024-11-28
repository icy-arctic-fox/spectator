require "../matchable"

module Spectator::Matchers::BuiltIn
  struct RespondToMatcher(NT)
    include Matchable

    def description
      "respond to #{method_name}"
    end

    def matches?(actual_value)
      {% begin %}
        actual_value.responds_to?({{NT.keys.first.symbolize}})
      {% end %}
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << description_of(actual_value) << " to respond to " << method_name
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected: " << description_of(actual_value) << " not to respond to " << method_name
    end

    private def method_name : Symbol
      {{NT.keys.first.symbolize}}
    end
  end
end
