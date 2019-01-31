require "./matcher"

module Spectator::Matchers
  # Category of matcher that checks if an actual value satisfies a condition.
  # Sub-types must implement `#match?`, `#message`, and `#negated_message`.
  # Those methods accept a `ValueExpectationPartial` to work with.
  abstract struct ConditionMatcher < Matcher
  end
end
