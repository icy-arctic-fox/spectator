require "../test_value"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Provides common methods for matchers.
  abstract struct StandardMatcher < Matcher
    # Message displayed when the matcher isn't satisifed.
    # This is only called when `#matches?` returns false.
    private abstract def failure_message(actual) : String

    # Message displayed when the matcher isn't satisifed and is negated.
    # This is only called when `#does_not_match?` returns false.
    #
    # A default implementation of this method is provided,
    # which causes compilation to fail.
    # If the matcher supports negation, it must override this method.
    private def failure_message_when_negated(actual) : String
      {% raise "Negation with #{@type.name} is not supported." %}
    end

    # Checks whether the matcher is satisifed.
    private abstract def match?(actual) : Bool

    # If the expectation is negated, then this method is called instead of `#match?`.
    # The default implementation of this method is to invert the result of `#match?`.
    # If the matcher requires custom handling of negated matches,
    # then this method should be overriden.
    # Remember to override `#failure_message_when_negated` as well.
    private def does_not_match?(actual) : Bool
      !match?(actual)
    end

    private def values(actual)
      {actual: actual.value.inspect}
    end

    private def negated_values(actual)
      values(actual)
    end

    def match(actual)
      if match?(actual)
        SuccessfulMatchData.new
      else
        FailedMatchData.new(failure_message(actual), **values(actual))
      end
    end

    def negated_match(actual)
      if does_not_match?(actual)
        SuccessfulMatchData.new
      else
        FailedMatchData.new(failure_message_when_negated(actual), **negated_values(actual))
      end
    end
  end
end
