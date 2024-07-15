require "../assertion_failed"
require "../core/location_range"

module Spectator::Matchers
  struct Expect(T)
    def initialize(@actual_value : T)
    end

    def to(matcher, failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Matchers.process_matcher(matcher, @actual_value,
        failure_message: failure_message,
        location: location)
      match_data.success? ? pass(match_data, location) : fail(match_data, location)
    end

    def not_to(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Matchers.process_negative_matcher(matcher, @actual_value,
        failure_message: failure_message,
        location: location)
      match_data.success? ? pass(match_data, location) : fail(match_data, location)
    end

    def to_not(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      not_to(matcher, failure_message,
        source_file: source_file,
        source_line: source_line,
        source_end_line: source_end_line)
    end

    private def pass(match_data, location)
      # TODO: Do something with the match data.
    end

    private def fail(match_data, location)
      raise AssertionFailed.new(match_data.message, location, match_data.fields)
    end
  end

  protected def self.process_matcher(matcher, actual_value, *,
                                     failure_message : String? = nil,
                                     location : Core::LocationRange? = nil) : MatchData
    try_positive_matcher(matcher, failure_message, location) ||
      try_positive_compatible_matcher(matcher, failure_message, location) ||
      raise "Unable to match #{matcher} with #{@actual_value.inspect}" # TODO: Improve error message.
  end

  protected def self.process_negative_matcher(matcher, actual_value, *,
                                              failure_message : String? = nil,
                                              location : Core::LocationRange? = nil) : MatchData
    try_negative_matcher(matcher, failure_message, location) ||
      try_negative_compatible_matcher(matcher, failure_message, location) ||
      try_inverted_compatible_matcher(matcher, failure_message, location) ||
      raise "Unable to match #{matcher} with #{@actual_value.inspect}" # TODO: Improve error message.
  end

  private def self.try_positive_matcher(matcher, actual_value, failure_message, location) : MatchData?
    return unless matcher.responds_to?(:match)
    match_data = matcher.match(actual_value, failure_message)
  end

  private def self.try_positive_compatible_matcher(matcher, actual_value, failure_message, location) : MatchData?
    return unless matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
    success = matcher.matches?(actual_value)
    Matchers::MatchData.new(success, false,
      message: failure_message || matcher.failure_message(actual_value))
  end

  private def self.try_negative_matcher(matcher, actual_value, failure_message, location) : MatchData?
    return unless matcher.responds_to?(:negated_match)
    matcher.negated_match(actual_value, failure_message)
  end

  private def self.try_negative_compatible_matcher(matcher, actual_value, failure_message, location) : MatchData?
    return unless matcher.responds_to?(:does_not_match?) && matcher.responds_to?(:negated_failure_message)
    success = matcher.does_not_match?(actual_value)
    Matchers::MatchData.new(success, true,
      message: failure_message || matcher.negated_failure_message(actual_value))
  end

  private def self.try_inverted_compatible_matcher(matcher, actual_value, failure_message, location) : MatchData?
    return unless matcher.responds_to?(:matches?) && matcher.responds_to?(:negated_failure_message)
    success = !matcher.matches?(actual_value)
    Matchers::MatchData.new(success, true,
      message: failure_message || matcher.negated_failure_message(actual_value))
  end

  module ExpectMethods
    def expect(actual_value : T) : Expect(T) forall T
      Expect(T).new(actual_value)
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::ExpectMethods
