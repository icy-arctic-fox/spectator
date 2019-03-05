require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, ends with a value.
  # The `ends_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Indexable` and the `last` value is compared against.
  struct EndWithMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(actual)
      compare_method(actual, &.eval(actual, expected))
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      values = ExpectedActual.new(partial, self)
      MatchData.new(match?(values.actual), values)
    end

    # Returns the method that should be used for comparison.
    # Call `eval(actual, expected)` on the returned value.
    private macro compare_method(actual, &block)
      # If the actual type defines `ends_with?`,
      # then use that for the comparison.
      # Otherwise, treat the actual type as an `Indexable`,
      # and retrieve the last value to compare with.
      # FIXME: Is there a better way to do this?
      if {{actual}}.responds_to?(:ends_with?)
        {{block.args.first}} = EndsWithCompareMethod.new
        {{block.body}}
      else
        {{block.args.first}} = IndexableCompareMethod.new
        {{block.body}}
      end
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
        method_string = compare_method(partial.actual, &.to_s)
        "#{values.actual_label} ends with #{values.expected_label} (using #{method_string})"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        method_string = compare_method(partial.actual, &.to_s)
        "#{values.actual_label} does not end with #{values.expected_label} (using #{method_string})"
      end
    end

    # Comparison method for types that define the `ends_with?` method.
    private struct EndsWithCompareMethod
      # Evaluates the condition to determine whether the matcher is satisfied.
      def eval(actual, expected)
        actual.ends_with?(expected)
      end

      # String representation for end-user output.
      def to_s
        "#ends_with?"
      end
    end

    # Comparison method for `Indexable` types.
    private struct IndexableCompareMethod
      # Evaluates the condition to determine whether the matcher is satisfied.
      def eval(actual, expected)
        expected === actual.last
      end

      # String representation for end-user output.
      def to_s
        "expected === actual.last"
      end
    end
  end
end
