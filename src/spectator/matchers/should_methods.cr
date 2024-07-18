require "./expectations"

module Spectator::Matchers
  module ShouldMethods
    def should(matcher, failure_message : String? = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Expectations.process_matcher(matcher, self,
        failure_message: failure_message,
        location: location)
      match_data.success? ? Expectations.pass(match_data, location) : Expectations.fail(match_data, location)
    end

    def should_not(matcher, failure_message : String? = nil, *,
                   source_file = __FILE__,
                   source_line = __LINE__,
                   source_end_line = __END_LINE__) : Nil
      location = Core::LocationRange.new(source_file, source_line, source_end_line)
      match_data = Expectations.process_negative_matcher(matcher, self,
        failure_message: failure_message,
        location: location)
      match_data.success? ? Expectations.pass(match_data, location) : Expectations.fail(match_data, location)
    end
  end
end

class Object
  include Spectator::Matchers::ShouldMethods
end
