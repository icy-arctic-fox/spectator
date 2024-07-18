require "../assertion_failed"
require "../core/location_range"
require "./expectations"

module Spectator::Matchers
  struct Expect(T)
    def initialize(@actual_value : T)
    end

    def to(matcher, failure_message : String? = nil, *,
           source_file = __FILE__,
           source_line = __LINE__,
           source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Expectations.process_matcher(matcher, @actual_value,
        failure_message: failure_message,
        location: location)
      match_data.success? ? Expectations.pass(match_data, location) : Expectations.fail(match_data, location)
    end

    def not_to(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Expectations.process_negative_matcher(matcher, @actual_value,
        failure_message: failure_message,
        location: location)
      match_data.success? ? Expectations.pass(match_data, location) : Expectations.fail(match_data, location)
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
  end

  module ExpectMethods
    def expect(actual_value : T) : Expect(T) forall T
      Expect(T).new(actual_value)
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::ExpectMethods
