require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value is truthy or falsey.
  # Falsey means a value is considered false by an if-statement,
  # which are false and nil in Crystal.
  # Truthy is the opposite of falsey.
  #
  # Additionally, different matchers can be created
  # by using the `#<`, `#<=`, `#>`, `#>=`, `#==`, and `#!=` operators.
  struct TruthyMatcher < Matcher
    # Creates the truthy matcher.
    # The *truthy* argument should be true to match "truthy" values,
    # and false to match "falsey" values.
    def initialize(@truthy : Bool)
    end

    # Textual representation of what the matcher expects.
    def label
      @truthy ? "truthy" : "falsey"
    end

    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      # Cast value to truthy value and compare.
      @truthy == !!actual
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      actual = partial.actual
      MatchData.new(match?(actual), @truthy, actual, partial.label)
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

    # Match data specific to this matcher.
    private struct MatchData(ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @truthy : Bool, @actual : ActualType, @actual_label : String)
        super(matched)
      end

      # Information about the match.
      def values
        truthy = "Not false or nil"
        falsey = "false or nil"
        {
          expected: AlternativeValue.new(@truthy ? truthy : falsey, @truthy ? falsey : truthy),
          actual:   @actual,
          truthy:   !!@actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@actual_label} is #{expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@actual_label} is not #{expected_label}"
      end

      # Textual representation of what the matcher expects.
      private def expected_label
        @truthy ? "truthy" : "falsey"
      end
    end
  end
end
