require "../formatters/printer"
require "../framework_error"
require "./formatting"

module Spectator::Matchers
  module Matchable
    include Formatting

    abstract def description

    abstract def matches?(actual_value)

    getter matcher_name do
      self.class.name.split("::").last.rchop("Matcher").underscore
    end

    def does_not_match?(actual_value)
      !matches?(actual_value)
    end

    def failure_message(actual_value)
      "Expected #{description_of actual_value} to #{description}"
    end

    def negated_failure_message(actual_value)
      "Expected #{description_of actual_value} not to #{description}"
    end

    def =~(other)
      matches?(other)
    end

    macro disable_negation
      private def no_negation!
        raise ::Spectator::FrameworkError.new("Matcher `#{matcher_name}` does not support negated matching.")
      end

      def does_not_match?(actual_value)
        no_negation!
      end

      def negated_failure_message(actual_value)
        no_negation!
      end
    end

    macro format_messages
      include ::Spectator::Matchers::Formatting::Printable
    end
  end
end
