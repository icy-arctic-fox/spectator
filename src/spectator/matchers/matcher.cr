module Spectator::Matchers
  module Matcher
    abstract def matches?(actual_value) : Bool

    def does_not_match?(actual_value) : Bool
      !matches?(actual_value)
    end

    abstract def failure_message(actual_value) : String

    def negated_failure_message(actual_value) : String
      raise FrameworkError.new("Matcher #{self.class} does not support negated matching.")
    end

    def self.process(matcher, actual_value, *,
                     failure_message : String? = nil,
                     location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
        return if matcher.matches?(actual_value)
        failure_message ||= matcher.failure_message(actual_value)
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching.")
      end
    end

    def self.process_negated(matcher, actual_value, *,
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
        failure_message ||= matcher.negated_failure_message(actual_value)
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
      end
    end

    def self.process_block(matcher, block, *,
                           failure_message : String? = nil,
                           location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
        return if matcher.matches?(&block)
        failure_message ||= matcher.failure_message(&block)
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching with a block.")
      end
    end

    def self.process_block_negated(matcher, block, *,
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
        failure_message ||= matcher.negated_failure_message(&block)
        AssertionFailed.new(failure_message, location)
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching with a block.")
      end
    end
  end
end
