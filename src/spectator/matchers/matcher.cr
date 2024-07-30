require "../assertion_failed"
require "../core/location_range"
require "../framework_error"

module Spectator::Matchers
  module Matcher
    extend self

    def match(matcher, actual_value, *,
              failure_message : String? = nil,
              location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
        return if matcher.matches?(actual_value)
        failure_message ||= matcher.failure_message(actual_value).to_s
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching.")
      end
    end

    def match_negated(matcher, actual_value, *,
                      failure_message : String? = nil,
                      location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:negated_failure_message)
        passed = if matcher.responds_to?(:does_not_match?)
                   matcher.does_not_match?(actual_value)
                 elsif matcher.responds_to?(:matches?)
                   !matcher.matches?(actual_value)
                 else
                   # TODO: Add more information, such as missing methods and suggestions.
                   raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
                 end
        return if passed
        failure_message ||= matcher.negated_failure_message(actual_value).to_s
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
      end
    end

    def match_block(matcher, block, *,
                    failure_message : String? = nil,
                    location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
        return if matcher.matches?(&block)
        failure_message ||= matcher.failure_message(&block).to_s
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching with a block.")
      end
    end

    def match_block_negated(matcher, block, *,
                            failure_message : String? = nil,
                            location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:negated_failure_message)
        passed = if matcher.responds_to?(:does_not_match?)
                   matcher.does_not_match?(&block)
                 elsif matcher.responds_to?(:matches?)
                   !matcher.matches?(&block)
                 else
                   # TODO: Add more information, such as missing methods and suggestions.
                   raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching with a block.")
                 end
        return if passed
        failure_message ||= matcher.negated_failure_message(&block).to_s
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching with a block.")
      end
    end
  end
end
