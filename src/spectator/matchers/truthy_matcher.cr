require "./standard_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is truthy or falsey.
  # Falsey means a value is considered false by an if-statement,
  # which are false and nil in Crystal.
  # Truthy is the opposite of falsey.
  #
  # Additionally, different matchers can be created
  # by using the `#<`, `#<=`, `#>`, `#>=`, `#==`, and `#!=` operators.
  struct TruthyMatcher < StandardMatcher
    # Creates the truthy matcher.
    # The *truthy* argument should be true to match "truthy" values,
    # and false to match "falsey" values.
    def initialize(@truthy : Bool = true)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "is #{label}"
    end

    # Creates a matcher that checks if a value is less than an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be < 1
    # ```
    def <(value)
      expected = Value.new(value)
      LessThanMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is less than or equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be <= 1
    # ```
    def <=(value)
      expected = Value.new(value)
      LessThanEqualMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is greater than an expected value.
    # The spec would look like:
    # ```
    # expect(2).to be > 1
    # ```
    def >(value)
      expected = Value.new(value)
      GreaterThanMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is greater than or equal to an expected value.
    # The spec would look like:
    # ```
    # expect(2).to be >= 1
    # ```
    def >=(value)
      expected = Value.new(value)
      GreaterThanEqualMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be == 0
    # ```
    def ==(value)
      expected = Value.new(value)
      EqualityMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is not equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be != 1
    # ```
    def !=(value)
      expected = Value.new(value)
      InequalityMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is semantically equal to an expected value.
    # The spec would look like:
    # ```
    # expect("foobar").to be === /foo/
    # ```
    def ===(value)
      expected = Value.new(value)
      PatternMatcher.new(expected)
    end

    # Creates a matcher that checks if a value matches the pattern of an expected value.
    # The spec would look like:
    # ```
    # expect("foobar").to be =~ /foo/
    # ```
    def =~(value)
      expected = Value.new(value)
      RegexMatcher.new(expected)
    end

    # Checks whether the matcher is satisfied with the expression given to it.
    private def match?(actual : Expression(T)) : Bool forall T
      @truthy == !!actual.value
    end

    # Message displayed when the matcher isn't satisfied.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} is #{negated_label}"
    end

    # Message displayed when the matcher isn't satisfied and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
      "#{actual.label} is #{label}"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      {
        expected: @truthy ? "Not false or nil" : "false or nil",
        actual:   actual.value.inspect,
        truthy:   (!!actual.value).inspect,
      }
    end

    # Additional information about the match failure when negated.
    # The return value is a NamedTuple with Strings for each value.
    private def negated_values(actual)
      {
        expected: @truthy ? "false or nil" : "Not false or nil",
        actual:   actual.value.inspect,
        truthy:   (!!actual.value).inspect,
      }
    end

    # Generated, user-friendly, string for the expected value.
    private def label
      @truthy ? "truthy" : "falsey"
    end

    # Generated, user-friendly, string for the unexpected value.
    private def negated_label
      @truthy ? "falsey" : "truthy"
    end
  end
end
