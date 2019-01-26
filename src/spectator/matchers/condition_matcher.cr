require "./matcher"

module Spectator::Matchers
  # Category of matcher that checks if an actual value satisfies a condition.
  # Sub-types must implement `#match?`, `#message`, and `#negated_message`.
  # Those methods accept a `ValueExpectationPartial` to work with.
  abstract struct ConditionMatcher < Matcher
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the matcher is satisfied, false otherwise.
    abstract def match?(partial : ValueExpectationPartial(ActualType)) : Bool forall ActualType

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    abstract def message(partial : ValueExpectationPartial(ActualType)) : String forall ActualType

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    abstract def negated_message(partial : ValueExpectationPartial(ActualType)) : String forall ActualType
  end
end
