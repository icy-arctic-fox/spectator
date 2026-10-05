require "../core/location_range"
require "./built_in/be_a_matcher"
require "./built_in/have_type_matcher"
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

    def should(matcher : BuiltIn::BeAMatcher(U) | BuiltIn::HaveTypeMatcher(U),
               failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : U forall U
      if failure = Matcher.match(matcher, @actual_value, failure_message)
        location = Core::LocationRange.new(source_file, source_line, source_end_line)
        failure.raise(location)
      else
        actual_value = @actual_value
        return actual_value if actual_value.is_a?(U)
        raise FrameworkError.new("Bug: Expected #{@actual_value} to be a #{U}")
      end
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
