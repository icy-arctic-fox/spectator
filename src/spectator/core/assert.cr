require "../assertion_failed"
require "./location_range"

module Spectator::Core
  module Assert
    def assert(value, message = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      return if value
      raise AssertionFailed.new("Assert failed: #{message || "Value was false"}",
        LocationRange.new(source_file, source_line, source_end_line))
    end

    def fail(message = nil, *,
             source_file = __FILE__,
             source_line = __LINE__,
             source_end_line = __END_LINE__) : Nil
      raise AssertionFailed.new(message || "Example failed",
        LocationRange.new(source_file, source_line, source_end_line))
    end

    def skip
      # TODO
    end
  end
end

include Spectator::Core::Assert
