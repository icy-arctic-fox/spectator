module Spectator::Matchers
  # Proxy type to provide the "be operator" syntax.
  # This allows users to write tests like:
  # ```
  # expect(1 + 1).to be > 1
  # ```
  struct BeComparison
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
