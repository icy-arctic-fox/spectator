module Spectator::Matchers
  # Base type for built-in and custom matchers (made with the DSL).
  # Ensures that the required methods are implemented.
  abstract struct Matcher
    abstract def matches?(actual_value) : Bool
    abstract def failure_message(actual_value) : String

    def ===(actual_value) : Bool
      matches?(actual_value)
    end
  end
end

# Matcher API:
#   - #matches?(actual)
#   - #failure_message
#   - #negated_failure_message
#   - #description
#   - #does_not_match?(actual)
#   - #===(actual)
