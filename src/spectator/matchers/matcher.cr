module Spectator::Matchers
  # Base type for built-in and custom matchers (made with the DSL).
  # Ensures that the required methods are implemented.
  abstract struct Matcher
    abstract def matches?(actual_value : T) : Bool
    abstract def failure_message(actual_value : T) : String
  end
end

# Matcher API:
#   - #matches?(actual)
#   - #failure_message
#   - #failure_message_when_negated
#   - #description
#   - #does_not_match?(actual)
#   - #===(actual)
