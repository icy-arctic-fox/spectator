require "../core/location_range"
require "./matcher"

module Spectator::Matchers
  module ShouldMethods
    def should(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      return unless failure = Matcher.match(matcher, self, failure_message)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure.raise(location)
    end

    def should_not(matcher, failure_message : String? = nil, *,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__) : Nil
      return unless failure = Matcher.match_negated(matcher, self, failure_message)
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      failure.raise(location)
    end
  end
end
