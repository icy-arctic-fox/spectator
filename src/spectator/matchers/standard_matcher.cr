require "../expression"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Provides common methods for matchers.
  #
  # The `#match` and `#negated_match` methods have an implementation
  # that is suitable for most matchers.
  # Matchers based on this class need to define `#match?` and `#failure_message`.
  # If the matcher can be negated,
  # the `#failure_message_when_negated` method needs to be overridden.
  # Additionally, the `#does_not_match?` method can be specified
  # if there's custom behavior for negated matches.
  # If the matcher operates on or has extra data that is useful for debug,
  # then the `#values` and `#negated_values` methods can be overridden.
  # Finally, define a `#description` message that can be used for the one-liner "it" syntax.
  abstract struct StandardMatcher < Matcher
    # Actually performs the test against the expression (value or block).
    #
    # This method calls the abstract `#match?` method.
    # If it returns true, then a `SuccessfulMatchData` instance is returned.
    # Otherwise, a `FailedMatchData` instance is returned.
    # Additionally, `#failure_message` and `#values` are called for a failed match.
    def match(actual : Expression(T)) : MatchData forall T
      if match?(actual)
        SuccessfulMatchData.new(match_data_description(actual))
      else
        FailedMatchData.new(match_data_description(actual), failure_message(actual), values(actual).to_a)
      end
    end

    # Performs the test against the expression (value or block), but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    #
    # This method calls the abstract `#does_not_match?` method.
    # If it returns true, then a `SuccessfulMatchData` instance is returned.
    # Otherwise, a `FailedMatchData` instance is returned.
    # Additionally, `#failure_message_when_negated` and `#negated_values` are called for a failed match.
    def negated_match(actual : Expression(T)) : MatchData forall T
      # TODO: Invert description.
      if does_not_match?(actual)
        SuccessfulMatchData.new(match_data_description(actual))
      else
        FailedMatchData.new(match_data_description(actual), failure_message_when_negated(actual), negated_values(actual).to_a)
      end
    end

    # Message displayed when the matcher isn't satisfied.
    #
    # This is only called when `#match?` returns false.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private abstract def failure_message(actual : Expression(T)) : String forall T

    # Message displayed when the matcher isn't satisfied and is negated.
    # This is essentially what would satisfy the matcher if it wasn't negated.
    #
    # This is only called when `#does_not_match?` returns false.
    #
    # A default implementation of this method is provided,
    # which causes compilation to fail.
    # If the matcher supports negation, it must override this method.
    #
    # The message should typically only contain the test expression labels.
    # Actual values should be returned by `#values`.
    private def failure_message_when_negated(actual : Expression(T)) : String forall T
      raise "Negation with #{self.class} is not supported."
    end

    # Checks whether the matcher is satisfied with the expression given to it.
    private abstract def match?(actual : Expression(T)) : Bool forall T

    # If the expectation is negated, then this method is called instead of `#match?`.
    #
    # The default implementation of this method is to invert the result of `#match?`.
    # If the matcher requires custom handling of negated matches,
    # then this method should be overridden.
    # Remember to override `#failure_message_when_negated` as well.
    private def does_not_match?(actual : Expression(T)) : Bool forall T
      !match?(actual)
    end

    # Additional information about the match failure.
    #
    # By default, just the actual value is produced.
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
    #
    # The values should typically only contain the test expression values, not the labels.
    # Labeled should be returned by `#failure_message`.
    private def values(actual : Expression(T)) forall T
      {actual: actual.value.inspect}
    end

    # Additional information about the match failure when negated.
    #
    # By default, just the actual value is produced (same as `#values`).
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
    #
    # The values should typically only contain the test expression values, not the labels.
    # Labeled should be returned by `#failure_message_when_negated`.
    private def negated_values(actual : Expression(T)) forall T
      values(actual)
    end
  end
end
