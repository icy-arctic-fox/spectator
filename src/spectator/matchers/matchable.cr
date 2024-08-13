require "../formatters/printer"
require "../framework_error"
require "./formatting"
require "./printable"

module Spectator::Matchers
  module Matchable
    include Formatting

    abstract def description

    abstract def matches?(actual_value)

    def matches?(&)
      matches?(yield)
    end

    getter matcher_name : String do
      self.class.name.split("::").last.rchop("Matcher").underscore
    end

    def does_not_match?(actual_value)
      !matches?(actual_value)
    end

    def does_not_match?(&)
      does_not_match?(yield)
    end

    def failure_message(actual_value)
      "Expected #{description_of actual_value} to #{description}"
    end

    def failure_message(&)
      failure_message(yield)
    end

    def negated_failure_message(actual_value)
      "Expected #{description_of actual_value} not to #{description}"
    end

    def negated_failure_message(&)
      negated_failure_message(yield)
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

      def does_not_match?(&)
        no_negation!
      end

      def negated_failure_message(actual_value)
        no_negation!
      end

      def negated_failure_message(&)
        no_negation!
      end
    end

    macro require_block
      private def no_block!
        raise ::Spectator::FrameworkError.new("Matcher `#{matcher_name}` must be used with a block.")
      end

      def matches?(actual_value)
        no_block!
      end

      def does_not_match?(actual_value)
        no_block!
      end

      def does_not_match?(&block)
        !matches?(&block)
      end

      def failure_message(actual_value)
        no_block!
      end

      def negated_failure_message(actual_value)
        no_block!
      end

      def failure_message(printer : ::Spectator::Matchers::FormattingPrinter, actual_value) : Nil
        no_block!
      end

      def negated_failure_message(printer : ::Spectator::Matchers::FormattingPrinter, actual_value) : Nil
        no_block!
      end
    end

    macro print_messages
      include ::Spectator::Matchers::Printable
    end
  end
end
