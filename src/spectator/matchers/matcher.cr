module Spectator::Matchers
  module Matcher
    abstract def matches?(actual_value) : Bool

    def does_not_match?(actual_value) : Bool
      !matches?(actual_value)
    end

    abstract def failure_message(actual_value) : String

    def negated_failure_message(actual_value) : String
      raise "Negated match of #{self.class} is not supported."
    end

    def self.process(matcher, actual_value, *,
                     failure_message : String? = nil,
                     location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
        return if matcher.matches?(actual_value)
        failure_message ||= matcher.failure_message(actual_value)
        AssertionFailed.new(failure_message, location)
      else
        raise "Unable to match #{matcher} with #{actual_value.inspect}" # TODO: Improve error message.
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
                   raise "Negated match of #{matcher.class} is not supported."
                 end
        return if passed
        failure_message ||= matcher.negated_failure_message(actual_value)
        AssertionFailed.new(failure_message, location)
      else
        raise "Matcher #{matcher} does not support negated match." # TODO: Improve error message.
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
        raise "Unable to match #{matcher} with block" # TODO: Improve error message.
      end
    end

    def self.process_negated_block(matcher, block, *,
                                   failure_message : String? = nil,
                                   location : Core::LocationRange? = nil) : AssertionFailed?
      if matcher.responds_to?(:negated_failure_message)
        passed = if matcher.responds_to?(:does_not_match?)
                   matcher.does_not_match?(&block)
                 elsif matcher.responds_to?(:matches?)
                   !matcher.matches?(&block)
                 else
                   raise "Negated match of #{matcher.class} is not supported."
                 end
        return if passed
        failure_message ||= matcher.negated_failure_message(&block)
        AssertionFailed.new(failure_message, location)
      else
        raise "Matcher #{matcher} does not support negated match." # TODO: Improve error message.
      end
    end
  end
end
