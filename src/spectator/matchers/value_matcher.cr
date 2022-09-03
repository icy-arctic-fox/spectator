require "../expression"
require "../value"
require "./standard_matcher"

module Spectator::Matchers
  # Category of matcher that uses a value.
  # Matchers of this type expect that a SUT applies to the value in some way.
  #
  # Matchers based on this class need to define `#match?` and `#failure_message`.
  # If the matcher can be negated,
  # the `#failure_message_when_negated` method needs to be overridden.
  # Additionally, the `#does_not_match?` method can be specified
  # if there's custom behavior for negated matches.
  # If the matcher operates on or has extra data that is useful for debug,
  # then the `#values` and `#negated_values` methods can be overridden.
  # Finally, define a `#description` message that can be used for the one-liner "it" syntax.
  #
  # The failure messages should typically only contain the test expression labels.
  # Actual values should be returned by `#values` and `#negated_values`.
  abstract struct ValueMatcher(ExpectedType) < StandardMatcher
    # Expected value.
    # Sub-types may use this value to test the expectation and generate message strings.
    private getter expected

    # Creates the value matcher.
    # The expected value is stored for later use.
    def initialize(@expected : ::Spectator::Value(ExpectedType))
    end

    # Additional information about the match failure.
    #
    # By default, just the actual and expected values are produced.
    # The return value must be a NamedTuple with Strings for each value.
    # The tuple can be of any size,
    # but the keys must be known at compile-time (as Symbols),
    # and the values must be strings.
    # Generally, the string values are produced by calling `#inspect` on the relevant object.
    # It should look like this:
    # ```
    # {
    #   expected: "foo",
    #   actual:   "bar",
    # }
    # ```
    private def values(actual : Expression(T)) forall T
      super.merge(expected: expected.value.inspect)
    end

    # Additional information about the match failure when negated.
    #
    # By default, just the actual and expected values are produced (same as `#values`).
    # However, the expected value is prefixed with the word "Not".
    # The return value must be a NamedTuple with Strings for each value.
    # The tuple can be of any size,
    # but the keys must be known at compile-time (as Symbols),
    # and the values must be strings.
    # Generally, the string values are produced by calling `#inspect` on the relevant object.
    # It should look like this:
    # ```
    # {
    #   expected: "Not foo",
    #   actual:   "bar",
    # }
    # ```
    private def negated_values(actual : Expression(T)) forall T
      super.merge(expected: "Not #{expected.value.inspect}")
    end
  end
end
