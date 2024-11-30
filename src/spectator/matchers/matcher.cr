require "../framework_error"

module Spectator::Matchers
  module Matcher
    def self.match(matcher, actual_value, failure_message : String? = nil) : MatchFailure?
      return matcher.match(actual_value) if matcher.responds_to?(:match)

      if matcher.responds_to?(:matches?)
        return if matcher.matches?(actual_value)

        return MatchFailure.new(failure_message) if failure_message

        if matcher.responds_to?(:print_failure_message)
          return MatchFailure.new do |printer|
            matcher.print_failure_message(printer, actual_value)
            nil
          end
        end

        if matcher.responds_to?(:failure_message)
          message = matcher.failure_message(actual_value).to_s
          return MatchFailure.new(message)
        end

        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} must implement `#failure_message` or `#print_failure_message`.")
      end

      # TODO: Add more information, such as missing methods and suggestions.
      raise FrameworkError.new("Object #{matcher} does not support matching.")
    end

    def self.match_negated(matcher, actual_value, failure_message : String? = nil) : MatchFailure?
      return matcher.match_negated(actual_value) if matcher.responds_to?(:match_negated)

      # Check if negated matching is supported.
      unless failure_message ||
             matcher.responds_to?(:print_negated_failure_message) ||
             matcher.responds_to?(:negated_failure_message)
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching. Implement `#negated_failure_message` or `#print_negated_failure_message`.")
      end

      return if matcher.responds_to?(:does_not_match?) && matcher.does_not_match?(actual_value)
      return if matcher.responds_to?(:matches?) && !matcher.matches?(actual_value)

      return MatchFailure.new(failure_message) if failure_message
      if failure = produce_negated_failure_message(matcher, actual_value)
        return failure
      end

      # TODO: Add more information, such as missing methods and suggestions.
      raise FrameworkError.new("Object #{matcher} does not support matching.")
    end

    private def self.produce_negated_failure_message(matcher, actual_value)
      if matcher.responds_to?(:print_negated_failure_message)
        return MatchFailure.new do |printer|
          matcher.print_negated_failure_message(printer, actual_value)
          nil
        end
      end

      if matcher.responds_to?(:negated_failure_message)
        message = matcher.negated_failure_message(actual_value).to_s
        return MatchFailure.new(message)
      end
    end

    def self.match_block(matcher, block, failure_message : String? = nil) : MatchFailure?
      return matcher.match(&block) if matcher.responds_to?(:match)

      if matcher.responds_to?(:matches?)
        return if matcher.matches?(&block)

        return MatchFailure.new(failure_message) if failure_message

        if matcher.responds_to?(:print_failure_message)
          return MatchFailure.new do |printer|
            matcher.print_failure_message(printer, &block)
            nil
          end
        end

        if matcher.responds_to?(:failure_message)
          message = matcher.failure_message(&block).to_s
          return MatchFailure.new(message)
        end

        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} must implement `#failure_message` or `#print_failure_message`.")
      end

      # TODO: Add more information, such as missing methods and suggestions.
      raise FrameworkError.new("Object #{matcher} does not support matching.")
    end

    def self.match_negated_block(matcher, block, failure_message : String? = nil) : MatchFailure?
      return matcher.match_negated(&block) if matcher.responds_to?(:match_negated)

      # Check if negated matching is supported.
      unless failure_message ||
             matcher.responds_to?(:print_negated_failure_message) ||
             matcher.responds_to?(:negated_failure_message)
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching. Implement `#negated_failure_message` or `#print_negated_failure_message`.")
      end

      return if matcher.responds_to?(:does_not_match?) && matcher.does_not_match?(&block)
      return if matcher.responds_to?(:matches?) && !matcher.matches?(&block)

      return MatchFailure.new(failure_message) if failure_message
      if failure = produce_negated_failure_message_block(matcher, &block)
        return failure
      end

      # TODO: Add more information, such as missing methods and suggestions.
      raise FrameworkError.new("Object #{matcher} does not support matching.")
    end

    private def self.produce_negated_failure_message_block(matcher, &block)
      if matcher.responds_to?(:print_negated_failure_message)
        return MatchFailure.new do |printer|
          matcher.print_negated_failure_message(printer, &block)
          nil
        end
      end

      if matcher.responds_to?(:negated_failure_message)
        message = matcher.negated_failure_message(&block).to_s
        return MatchFailure.new(message)
      end
    end
  end
end
