require "../assertion_failed"
require "../example_skipped"
require "./location_range"

module Spectator::Core
  # Methods for asserting in examples.
  # These are lower-level methods that can be used in more complex use-cases,
  # but there are generally better ways to do this.
  module Assert
    # Asserts that the *value* is true.
    # If it is not, an `AssertionFailed` error is raised.
    # Otherwise, the method returns normally.
    # An optional *message* can be provided to describe the assertion.
    def assert(value, message = nil, *,
               source_file = __FILE__,
               source_line = __LINE__,
               source_end_line = __END_LINE__) : Nil
      return if value
      raise AssertionFailed.new("Assert failed: #{message || "Value was false"}",
        LocationRange.new(source_file, source_line, source_end_line))
    end

    # Raises an `AssertionFailed` error.
    # This is typically used to indicate an example failed.
    # An optional *message* can be provided to describe the failure.
    def fail(message = nil, *,
             source_file = __FILE__,
             source_line = __LINE__,
             source_end_line = __END_LINE__) : Nil
      raise AssertionFailed.new(message || "Example failed",
        LocationRange.new(source_file, source_line, source_end_line))
    end

    # Raises an `ExampleSkipped` error.
    # This is typically used to indicate an example was skipped.
    # An optional *message* can be provided to describe why the example was skipped.
    def skip(message = nil, *,
             source_file = __FILE__,
             source_line = __LINE__,
             source_end_line = __END_LINE__) : Nil
      raise ExampleSkipped.new(message,
        LocationRange.new(source_file, source_line, source_end_line))
    end
  end
end

include Spectator::Core::Assert
