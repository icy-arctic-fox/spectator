require "./matcher"

module Spectator::Matchers
  # Category of matcher that uses a value.
  # Matchers of this type expect that a SUT applies to the value in some way.
  # Sub-types must implement `#match`, `#message`, and `#negated_message`.
  # Those methods accept a `ValueExpectationPartial` to work with.
  abstract struct ValueMatcher(ExpectedType) < Matcher
    # Expected value.
    # Sub-types may use this value to test the expectation and generate message strings.
    private getter expected

    # Creates the value matcher.
    # The label should be a string representation of the expectation.
    # The expected value is stored for later use.
    def initialize(label : String, @expected : ExpectedType)
      super(label)
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    abstract def match?(partial : ValueExpectationPartial(ActualType)) : Bool forall ActualType

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    abstract def message(partial : ValueExpectationPartial(ActualType)) : String forall ActualType

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    abstract def negated_message(partial : ValueExpectationPartial(ActualType)) : String forall ActualType
  end
end
