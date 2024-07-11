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
      validate_matcher(matcher)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      if matcher.matches?(@actual_value)
        pass(location)
      else
        fail(failure_message || matcher.failure_message(@actual_value), location)
      end
    end

    def not_to(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      validate_matcher(matcher)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      if matcher.responds_to?(:does_not_match?) && matcher.does_not_match?(@actual_value)
        pass(location)
      elsif !matcher.matches?(@actual_value)
        pass(location)
      elsif !failure_message && matcher.responds_to?(:negated_failure_message)
        fail(matcher.negated_failure_message(@actual_value), location)
      else
        fail(failure_message || matcher.failure_message(@actual_value), location)
      end
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

    private def pass(location)
    end

    private def fail(message, location)
      raise AssertionFailed.new(message) # TODO: location
    end

    private def validate_matcher(matcher)
      raise ArgumentError.new("Matcher must respond to #matches?") unless matcher.responds_to?(:matches?)
      raise ArgumentError.new("Matcher must respond to #failure_message") unless matcher.responds_to?(:failure_message)
    end
  end

  module ExpectMethods
    def expect(actual_value : T) : Spectator::Matchers::Expect(T) forall T
      Spectator::Matchers::Expect(T).new(actual_value)
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::ExpectMethods
