require "../core/location_range"
require "../framework_error"
require "./match_data"

module Spectator::Matchers
  module Matcher
    extend self

    def match(matcher, actual_value, *,
              failure_message : String? = nil,
              location : Core::LocationRange? = nil) : MatchData
      if matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
        if matcher.matches?(actual_value)
          Matchers.passed(location)
        else
          if failure_message
            Matchers.failed(failure_message, location)
          elsif matcher.responds_to?(:format_failure_message)
            Matchers.failed(location) do |printer|
              matcher.format_failure_message(printer, actual_value)
            end
          else
            failure_message = matcher.failure_message(actual_value).to_s
            Matchers.failed(failure_message, location)
          end
        end
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching.")
      end
    end

    def match_negated(matcher, actual_value, *,
                      failure_message : String? = nil,
                      location : Core::LocationRange? = nil) : MatchData
      if matcher.responds_to?(:negated_failure_message)
        passed = if matcher.responds_to?(:does_not_match?)
                   matcher.does_not_match?(actual_value)
                 elsif matcher.responds_to?(:matches?)
                   !matcher.matches?(actual_value)
                 else
                   # TODO: Add more information, such as missing methods and suggestions.
                   raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
                 end
        if passed
          Matchers.passed(location)
        else
          failure_message ||= matcher.negated_failure_message(actual_value).to_s
          Matchers.failed(failure_message, location)
        end
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching.")
      end
    end

    def match_block(matcher, block, *,
                    failure_message : String? = nil,
                    location : Core::LocationRange? = nil) : MatchData
      if matcher.responds_to?(:matches?) && matcher.responds_to?(:failure_message)
        if matcher.matches?(&block)
          Matchers.passed(location)
        else
          failure_message ||= matcher.failure_message(&block).to_s
          Matchers.failed(failure_message, location)
        end
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support matching with a block.")
      end
    end

    def match_block_negated(matcher, block, *,
                            failure_message : String? = nil,
                            location : Core::LocationRange? = nil) : MatchData
      if matcher.responds_to?(:negated_failure_message)
        passed = if matcher.responds_to?(:does_not_match?)
                   matcher.does_not_match?(&block)
                 elsif matcher.responds_to?(:matches?)
                   !matcher.matches?(&block)
                 else
                   # TODO: Add more information, such as missing methods and suggestions.
                   raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching with a block.")
                 end
        if passed
          Matchers.passed(location)
        else
          failure_message ||= matcher.negated_failure_message(&block).to_s
          Matchers.failed(failure_message, location)
        end
      else
        # TODO: Add more information, such as missing methods and suggestions.
        raise FrameworkError.new("Matcher #{matcher.class} does not support negated matching with a block.")
      end
    end
  end
end
