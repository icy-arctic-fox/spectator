require "../expect"
require "../matcher"

module Spectator::Matchers::BuiltIn
  struct AllMatcher(T) < Matcher
    def initialize(@matcher : T)
    end

    def match(actual_value, failure_message = nil) : MatchData
      raise "`all` matcher requires value to be `Enumerable`" unless actual_value.is_a?(Enumerable)
      actual_value.each_with_index do |value, index|
        match_data = Matchers.process_matcher(@matcher, value, failure_message: failure_message)
        next if match_data.success?
        return fail(
          message: match_data.message,
          fields: ["Element at index #{index} did not match", *match_data.fields])
      end
      pass
    end

    def negated_match(actual_value, failure_message = nil) : MatchData
      raise "`all` matcher requires value to be `Enumerable`" unless actual_value.is_a?(Enumerable)
      actual_value.each_with_index do |value, index|
        match_data = Matchers.process_negative_matcher(@matcher, value, failure_message: failure_message)
        next if match_data.success?
        return fail(
          negated: true,
          message: match_data.message,
          fields: ["Element at index #{index} matched", *match_data.fields])
      end
      pass(negated: true)
    end
  end
end
