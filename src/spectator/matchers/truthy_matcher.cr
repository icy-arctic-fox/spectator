require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is truthy or falsey.
  # Falsey means a value is considered false by an if-statement,
  # which are `false` and `nil` in Crystal.
  # Truthy is the opposite of falsey.
  struct TruthyMatcher < ValueMatcher(Bool)
    # Creates the truthy matcher.
    def initialize(truthy : Bool)
      super(truthy ? "truthy" : "falsey", truthy)
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial : Expectations::ValueExpectationPartial(ActualType)) : Bool forall ActualType
      # Cast value to truthy value and compare.
      @expected == !!partial.actual
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to be #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial : Expectations::ValueExpectationPartial(ActualType)) : String forall ActualType
      "Expected #{partial.label} to not be #{label}"
    end
  end
end
