require "../formatters"
require "../framework_error"

module Spectator::Matchers
  struct NegatedMatcher(T)
    def initialize(@matcher : T)
    end

    def description
      "not #{@matcher.description}"
    end

    {% for arg in ["actual_value".id, "&block".id] %}
      def match({{arg}}) : MatchFailure?
        Matcher.match_negated(@matcher, {{arg.id}})
      end

      def match_negated({{arg}}) : MatchFailure?
        Matcher.match(@matcher, {{arg}})
      end

      def matches?({{arg}})
        matcher = @matcher

        # Matcher.match_negated is not used here because it could perform additional work that isn't needed.
        return matcher.does_not_match?({{arg}}) if matcher.responds_to?(:does_not_match?)
        return !matcher.matches?({{arg}}) if matcher.responds_to?(:matches?)
        return !!matcher.match_negated({{arg}}) if matcher.responds_to?(:match_negated)
        return !matcher.match({{arg}}) if matcher.responds_to?(:match)

        raise FrameworkError.new("Object #{matcher} does not support matching.")
      end

      def does_not_match?({{arg.id}})
        matcher = @matcher

        # Matcher.match is not used here because it could perform additional work that isn't needed.
        return matcher.matches?({{arg}}) if matcher.responds_to?(:matches?)
        return !matcher.does_not_match?({{arg}}) if matcher.responds_to?(:does_not_match?)
        return !!matcher.match({{arg}}) if matcher.responds_to?(:match)
        return !matcher.match_negated({{arg}}) if matcher.responds_to?(:match_negated)

        raise FrameworkError.new("Object #{matcher} does not support matching.")
      end

      def failure_message({{arg}})
        matcher = @matcher
        if matcher.responds_to?(:negated_failure_message)
          matcher.negated_failure_message({{arg}})
        elsif matcher.responds_to?(:print_negated_failure_message)
          Formatters.stringify do |printer|
            matcher.print_negated_failure_message(printer, {{arg}})
          end
        else
          raise FrameworkError.new("Object #{matcher} does not support negated matching.")
        end
      end

      def print_failure_message(printer : Formatters::Printer, {{arg}}) : Nil
        matcher = @matcher
        if matcher.responds_to?(:print_negated_failure_message)
          matcher.print_negated_failure_message(printer, {{arg}})
        elsif matcher.responds_to?(:negated_failure_message)
          printer << matcher.negated_failure_message({{arg}})
        else
          raise FrameworkError.new("Object #{matcher} does not support negated matching.")
        end
      end

      def negated_failure_message({{arg}})
        matcher = @matcher
        if matcher.responds_to?(:failure_message)
          matcher.negated_failure_message({{arg}})
        elsif matcher.responds_to?(:print_failure_message)
          Formatters.stringify do |printer|
            matcher.print_failure_message(printer, {{arg}})
          end
        else
          raise FrameworkError.new("Object #{matcher} does not support matching.")
        end
      end

      def print_negated_failure_message(printer : Formatters::Printer, {{arg}}) : Nil
        matcher = @matcher
        if matcher.responds_to?(:print_failure_message)
          matcher.print_failure_message(printer, {{arg}})
        elsif matcher.responds_to?(:failure_message)
          printer << matcher.failure_message({{arg}})
        else
          raise FrameworkError.new("Object #{matcher} does not support matching.")
        end
      end
    {% end %}
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
