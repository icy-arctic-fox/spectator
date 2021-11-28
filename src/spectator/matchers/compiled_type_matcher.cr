require "./matcher"

module Spectator::Matchers
  # Matcher that tests a value is of a specified type at compile time.
  # The values are compared with the `typeof` method.
  # This can be used to inspect the inferred type of methods and variables.
  struct CompiledTypeMatcher(Expected) < StandardMatcher
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "compiles as #{Expected}"
    end

    # Checks whether the matcher is satisfied with the expression given to it.
    private def match?(actual : Expression(T)) : Bool forall T
      Expected == typeof(actual.value)
    end

    # Message displayed when the matcher isn't satisfied.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} does not compile as #{Expected}"
    end

    # Message displayed when the matcher isn't satisfied and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
      "#{actual.label} compiles as #{Expected}"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      {
        expected: Expected.to_s,
        actual:   typeof(actual.value).inspect,
      }
    end

    # Additional information about the match failure when negated.
    # The return value is a NamedTuple with Strings for each value.
    private def negated_values(actual)
      {
        expected: "Not #{Expected}",
        actual:   typeof(actual.value).inspect,
      }
    end
  end
end
