require "../core/location_range"
require "./matcher"

module Spectator::Matchers
  module ShouldMethods
    def should(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Matcher.match(matcher, self,
        failure_message: failure_message,
        location: location)
      match_data.try_raise
    end

    def should_not(matcher, failure_message : String? = nil, *,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Matcher.match_negated(matcher, self,
        failure_message: failure_message,
        location: location)
      match_data.try_raise
    end
  end
end
