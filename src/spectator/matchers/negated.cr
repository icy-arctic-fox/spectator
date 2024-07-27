require "../framework_error"

module Spectator::Matchers
  struct NegatedMatcher(T)
    def initialize(@matcher : T)
    end

    def matches?(actual_value) : Bool
      matcher = @matcher
      if matcher.responds_to?(:negated_failure_message)
        if matcher.responds_to?(:does_not_match?)
          matcher.does_not_match?(actual_value)
        elsif matcher.responds_to?(:matches?)
          !matcher.matches?(actual_value)
        else
          # TODO: Add more information, such as missing methods and suggestions.
          raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
        end
      else
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
      end
    end

    def does_not_match?(actual_value) : Bool
      matcher = @matcher
      if matcher.responds_to?(:matches?)
        matcher.matches?(actual_value)
      else
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching.")
      end
    end

    def failure_message(actual_value) : String
      matcher = @matcher
      if matcher.responds_to?(:negated_failure_message)
        matcher.negated_failure_message(actual_value)
      else
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
      end
    end

    def negated_failure_message(actual_value) : String
      matcher = @matcher
      if matcher.responds_to?(:failure_message)
        matcher.failure_message(actual_value)
      else
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching.")
      end
    end
  end

  module Negated
  end

  macro define_negated_matcher(negated_matcher, matcher)
    module ::Spectator::Matchers::Negated
      def {{negated_matcher.id}}(*args, **options)
        matcher = {{matcher.id}}.new(*args, **options)
        ::Spectator::Matchers::NegatedMatcher.new(matcher)
      end

      def {{negated_matcher.id}}(*args, **options, &block)
        matcher = {{matcher.id}}.new(*args, **options, &block)
        ::Spectator::Matchers::NegatedMatcher.new(matcher)
      end
    end
  end
end

# TODO: Is it possible to move this out of the global namespace?
include Spectator::Matchers::Negated
