require "./matcher"

module Spectator::Matchers
  # Matcher that tests a value is of a specified type.
  # The values are compared with the `Object#is_a?` method.
  struct TypeMatcher(Expected) < StandardMatcher
    # Alternate constructor that works with constant types and types from variables.
    def self.create(type : T.class) forall T
      TypeMatcher(T).new
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "is a #{Expected}"
    end

    # Checks whether the matcher is satisfied with the expression given to it.
    private def match?(actual : Expression(T)) : Bool forall T
      actual.value.is_a?(Expected)
    end

    # Message displayed when the matcher isn't satisfied.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message(actual) : String
      "#{actual.label} is not a #{Expected}"
    end

    # Message displayed when the matcher isn't satisfied and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual) : String
      "#{actual.label} is a #{Expected}"
    end

    # Additional information about the match failure.
    # The return value is a NamedTuple with Strings for each value.
    private def values(actual)
      {
        expected: Expected.to_s,
        actual:   actual.value.class.inspect,
      }
    end

    # Additional information about the match failure when negated.
    # The return value is a NamedTuple with Strings for each value.
    private def negated_values(actual)
      {
        expected: "Not #{Expected}",
        actual:   actual.value.class.inspect,
      }
    end
  end
end
