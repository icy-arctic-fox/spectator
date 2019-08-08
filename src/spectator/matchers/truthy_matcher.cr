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

    private def label
      @truthy ? "truthy" : "falsey"
    end

    private def negated_label
      @truthy ? "falsey" : "truthy"
    end

    private def match?(actual)
      @truthy == !!actual.value
    end

    def description
      "is #{label}"
    end

    private def failure_message(actual)
      "#{actual.label} is #{negated_label}"
    end

    private def failure_message_when_negated(actual)
      "#{actual.label} is #{label}"
    end

    private def values(actual)
      {
        expected: @truthy ? "Not false or nil" : "false or nil",
        actual:   actual.value.inspect,
        truthy:   !!actual.value.inspect,
      }
    end

    private def negated_values(actual)
      {
        expected: @truthy ? "false or nil" : "Not false or nil",
        actual:   actual.value.inspect,
        truthy:   !!actual.value.inspect,
      }
    end

    # Creates a matcher that checks if a value is less than an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be < 1
    # ```
    def <(value : ExpectedType) forall ExpectedType
      expected = TestValue.new(value)
      LessThanMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is less than or equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be <= 1
    # ```
    def <=(value : ExpectedType) forall ExpectedType
      expected = TestValue.new(value)
      LessThanEqualMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is greater than an expected value.
    # The spec would look like:
    # ```
    # expect(2).to be > 1
    # ```
    def >(value : ExpectedType) forall ExpectedType
      expected = TestValue.new(value)
      GreaterThanMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is greater than or equal to an expected value.
    # The spec would look like:
    # ```
    # expect(2).to be >= 1
    # ```
    def >=(value : ExpectedType) forall ExpectedType
      expected = TestValue.new(value)
      GreaterThanEqualMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be == 0
    # ```
    def ==(value : ExpectedType) forall ExpectedType
      expected = TestValue.new(value)
      EqualityMatcher.new(expected)
    end

    # Creates a matcher that checks if a value is not equal to an expected value.
    # The spec would look like:
    # ```
    # expect(0).to be != 1
    # ```
    def !=(value : ExpectedType) forall ExpectedType
      expected = TestValue.new(value)
      InequalityMatcher.new(expected)
    end
  end
end
