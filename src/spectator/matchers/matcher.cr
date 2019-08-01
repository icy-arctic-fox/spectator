require "./failed_matched_data"
require "./successful_match_data"

module Spectator::Matchers
  # Common base class for all expectation conditions.
  # A matcher looks at something produced by the SUT
  # and evaluates whether it is correct or not.
  abstract struct Matcher
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    # ```
    # it { is_expected.to do_something }
    # ```
    # The phrasing should be such that it reads "it ___."
    abstract def description : String

    # Message displayed when the matcher isn't satisifed.
    # This is only called when `#matches?` returns false.
    abstract def failure_message : String

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is only called when `#does_not_match?` returns false.
    #
    # A default implementation of this method is provided,
    # which causes compilation to fail.
    # If the matcher supports negation, it must override this method.
    def failure_message_when_negated : String
      {% raise "Negation with #{@type.name} is not supported."}
    end

    # Checks whether the matcher is satisifed.
    private abstract def match?(actual) : Bool

    # If the expectation is negated, then this method is called instead of `#match?`.
    # The default implementation of this method is to invert the result of `#match?`.
    # If the matcher requires custom handling of negated matches,
    # then this method should be overriden.
    # Remember to override `#failure_message_when_negated` as well.
    private def does_not_match?(actual) : Bool
      !matches?(actual)
    end

    private def values(actual) : Array(LabeledValue)
      [LabeledValue.new(:actual, actual.value)]
    end

    private def negated_values(actual) : Array(LabeledValue)
      values
    end

    def match(actual)
      if match?(actual)
        SuccessfulMatchData.new
      else
        FailedMatchData.new(failure_message, values)
      end
    end

    def negated_match(actual)
      if does_not_match?(actual)
        SuccessfulMatchData.new
      else
        FailedMatchData.new(failure_message_when_negated, negated_values)
      end
    end
  end
end
