require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, matches one or more values.
  # For a `String`, the `includes?` method is used.
  # Otherwise, it expects an `Enumerable` and iterates over each item until === is true.
  struct HaveMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    private def match?(actual)
      if actual.is_a?(String)
        match_string?(actual)
      else
        match_enumerable?(actual)
      end
    end

    # Checks if a `String` matches the expected values.
    # The `includes?` method is used for this check.
    private def match_string?(actual)
      expected.all? do |item|
        actual.includes?(item)
      end
    end

    # Checks if an `Enumerable` matches the expected values.
    # The `===` operator is used on every item.
    private def match_enumerable?(actual)
      array = actual.to_a
      expected.all? do |item|
        array.any? do |elem|
          item === elem
        end
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
          subset:   @values.expected,
          superset: @values.actual,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} includes #{@values.expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not include #{@values.expected_label}"
      end
    end
  end
end
