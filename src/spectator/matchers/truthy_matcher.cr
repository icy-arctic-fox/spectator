require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is truthy or falsey.
  # Falsey means a value is considered false by an if-statement,
  # which are `false` and `nil` in Crystal.
  # Truthy is the opposite of falsey.
  #
  # Additionally, different matchers can be created
  # by using the `#<`, `#<=`, `#>`, `#>=`, `#==`, and `#!=` operators.
  struct TruthyMatcher < ValueMatcher(Bool)
    # Creates the truthy matcher.
    # The `truthy` argument should be true to match "truthy" values,
    # and false to match "falsey" values.
    def initialize(truthy : Bool)
      super(truthy ? "truthy" : "falsey", truthy)
    end

    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial) : Bool
      # Cast value to truthy value and compare.
      @expected == !!partial.actual
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial) : String
      "Expected #{partial.label} to be #{label}"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial) : String
      "Expected #{partial.label} to not be #{label}"
    end

    # Creates a matcher that checks if a value is less than an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be < 1
    # ```
    def <(expected : ExpectedType) forall ExpectedType
      LessThanMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is less than or equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be <= 1
    # ```
    def <=(expected : ExpectedType) forall ExpectedType
      LessThanEqualMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is greater than an expected value.
    # The spec would look like:
    # ```
    # expect(2).to be > 1
    # ```
    def >(expected : ExpectedType) forall ExpectedType
      GreaterThanMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is greater than or equal to an expected value.
    # The spec would look like:
    # ```
    # expect(2).to be >= 1
    # ```
    def >=(expected : ExpectedType) forall ExpectedType
      GreaterThanEqualMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be == 0
    # ```
    def ==(expected : ExpectedType) forall ExpectedType
      EqualityMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is not equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be != 1
    # ```
    def !=(expected : ExpectedType) forall ExpectedType
      InequalityMatcher.new(expected)
    end
  end
end
