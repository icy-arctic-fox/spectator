require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, ends with a value.
  # The `ends_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Indexable` and the `last` value is compared against.
  struct EndWithMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      if actual.responds_to?(:ends_with?)
        actual.ends_with?(expected)
      else
        expected === actual.last
      end
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      values = ExpectedActual.new(partial, self)
      MatchData.new(match?(values.actual), values)
    end

    # Match data specific to this matcher.
    private struct MatchData(ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def values
        {
          expected: @values.expected,
          actual:   @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} ends with #{@values.expected_label} (using #{comparison_method})"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not end with #{@values.expected_label} (using #{comparison_method})"
      end

      private def comparison_method
        if @values.actual.responds_to?(:ends_with?)
          "#ends_with?"
        else
          "expected === actual.last"
        end
      end
    end
  end
end
