require "../assertion_failed"
require "../core/location_range"
require "./match_data"

module Spectator::Matchers
  module Expectations
    extend self

    def process_matcher(matcher, actual_value, *,
                        failure_message : String? = nil,
                        location : Core::LocationRange? = nil) : MatchData
      try_positive_matcher(matcher, actual_value, failure_message, location) ||
        try_positive_compatible_matcher(matcher, actual_value, failure_message, location) ||
        raise "Unable to match #{matcher} with #{actual_value.inspect}" # TODO: Improve error message.
    end

    def process_negative_matcher(matcher, actual_value, *,
                                 failure_message : String? = nil,
                                 location : Core::LocationRange? = nil) : MatchData
      try_negative_matcher(matcher, actual_value, failure_message, location) ||
        try_negative_compatible_matcher(matcher, actual_value, failure_message, location) ||
        try_inverted_compatible_matcher(matcher, actual_value, failure_message, location) ||
        raise "Unable to match #{matcher} with #{actual_value.inspect}" # TODO: Improve error message.
    end

    private def try_positive_matcher(matcher, actual_value, failure_message, location) : MatchData?
      return unless matcher.responds_to?(:match)
      match_data = matcher.match(actual_value, failure_message)
    end

    private def try_positive_compatible_matcher(matcher, actual_value, failure_message, location) : MatchData?
      return unless matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
      success = matcher.matches?(actual_value)
      Matchers::MatchData.new(success, false,
        message: failure_message || matcher.failure_message(actual_value))
    end

    private def try_negative_matcher(matcher, actual_value, failure_message, location) : MatchData?
      return unless matcher.responds_to?(:negated_match)
      matcher.negated_match(actual_value, failure_message)
    end

    private def try_negative_compatible_matcher(matcher, actual_value, failure_message, location) : MatchData?
      return unless matcher.responds_to?(:does_not_match?) && matcher.responds_to?(:negated_failure_message)
      success = matcher.does_not_match?(actual_value)
      Matchers::MatchData.new(success, true,
        message: failure_message || matcher.negated_failure_message(actual_value))
    end

    private def try_inverted_compatible_matcher(matcher, actual_value, failure_message, location) : MatchData?
      return unless matcher.responds_to?(:matches?) && matcher.responds_to?(:negated_failure_message)
      success = !matcher.matches?(actual_value)
      Matchers::MatchData.new(success, true,
        message: failure_message || matcher.negated_failure_message(actual_value))
    end

    def pass(match_data, location)
      # TODO: Do something with the match data.
    end

    def fail(match_data, location)
      raise AssertionFailed.new(match_data.message, location, match_data.fields)
    end
  end
end
