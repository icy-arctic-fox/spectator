require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether a value, such as a `String` or `Array`, starts with a value.
  # The `starts_with?` method is used if it's defined on the actual type.
  # Otherwise, it is treated as an `Enumerable` and the `first` value is compared against.
  struct StartWithMatcher(ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    # True is returned if the match was successful, false otherwise.
    def match?(partial)
      actual = partial.actual
      compare_method(actual, &.eval(actual, expected))
    end

    # Describes the condition that satisfies the matcher.
    # This is informational and displayed to the end-user.
    def message(partial)
      method_string = compare_method(partial.actual, &.to_s)
      "Expected #{partial.label} to start with #{label} (using #{method_string})"
    end

    # Describes the condition that won't satsify the matcher.
    # This is informational and displayed to the end-user.
    def negated_message(partial)
      method_string = compare_method(partial.actual, &.to_s)
      "Expected #{partial.label} to not start with #{label} (using #{method_string})"
    end

    # Returns the method that should be used for comparison.
    # Call `eval(actual, expected)` on the returned value.
    private macro compare_method(actual, &block)
      # If the actual type defines `starts_with?`,
      # then use that for the comparison.
      # Otherwise, treat the actual type as an `Enumerable`,
      # and retrieve the first value to compare with.
      # FIXME: Is there a better way to do this?
      if {{actual}}.responds_to?(:starts_with?)
        {{block.args.first}} = StartsWithCompareMethod.new
        {{block.body}}
      else
        {{block.args.first}} = EnumerableCompareMethod.new
        {{block.body}}
      end
    end

    # Comparison method for types that define the `starts_with?` method.
    private struct StartsWithCompareMethod
      # Evaluates the condition to determine whether the matcher is satisfied.
      def eval(actual, expected)
        actual.starts_with?(expected)
      end

      # String representation for end-user output.
      def to_s
        "#starts_with?"
      end
    end

    # Comparison method for `Enumerable` types.
    private struct EnumerableCompareMethod
      # Evaluates the condition to determine whether the matcher is satisfied.
      def eval(actual, expected)
        expected === actual.first
      end

      # String representation for end-user output.
      def to_s
        "expected === actual.first"
      end
    end
  end
end
