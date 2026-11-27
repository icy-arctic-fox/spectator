require "../formatters"
require "../framework_error"
require "./formatting"
require "./match_failure"

module Spectator::Matchers
  module Matchable
    include Formatting

    getter matcher_name : String do
      self.class.name.split("::").last.rchop("Matcher").underscore
    end

    abstract def matches?(actual_value)

    def matches?(&)
      matches?(yield)
    end

    def does_not_match?(actual_value)
      !matches?(actual_value)
    end

    def does_not_match?(&)
      does_not_match?(yield)
    end

    def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " to " << self
    end

    def print_failure_message(printer : Formatters::Printer, &) : Nil
      print_failure_message(printer, yield)
    end

    def failure_message(actual_value)
      Formatters.stringify do |printer|
        print_failure_message(printer, actual_value)
      end
    end

    def failure_message(&)
      failure_message(yield)
    end

    def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
      printer << "Expected " << description_of(actual_value) << " not to " << self
    end

    def print_negated_failure_message(printer : Formatters::Printer, &) : Nil
      print_negated_failure_message(printer, yield)
    end

    def negated_failure_message(actual_value)
      Formatters.stringify do |printer|
        print_negated_failure_message(printer, actual_value)
      end
    end

    def negated_failure_message(&)
      negated_failure_message(yield)
    end

    def ===(other)
      matches?(other)
    end

    def match(actual_value) : MatchFailure?
      return if matches?(actual_value)
      MatchFailure.new do |printer|
        print_failure_message(printer, actual_value)
      end
    end

    def match(&block) : MatchFailure?
      return if matches?(&block)
      MatchFailure.new do |printer|
        print_failure_message(printer, &block)
      end
    end

    def match_negated(actual_value) : MatchFailure?
      return if does_not_match?(actual_value)
      MatchFailure.new do |printer|
        print_negated_failure_message(printer, actual_value)
      end
    end

    def match_negated(&block) : MatchFailure?
      return if does_not_match?(&block)
      MatchFailure.new do |printer|
        print_negated_failure_message(printer, &block)
      end
    end

    macro disable_negation
      private def negation_disabled!
        raise ::Spectator::FrameworkError.new("Matcher `#{matcher_name}` does not support negated matching.")
      end

      def does_not_match?(actual_value)
        negation_disabled!
      end

      def does_not_match?(&)
        negation_disabled!
      end

      def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
        negation_disabled!
      end

      def print_negated_failure_message(printer : Formatters::Printer, &) : Nil
        negation_disabled!
      end

      def negated_failure_message(actual_value)
        negation_disabled!
      end

      def negated_failure_message(&)
        negation_disabled!
      end
    end

    macro require_block
      private def block_required!
        raise ::Spectator::FrameworkError.new("Matcher `#{matcher_name}` must be used with a block.")
      end

      def matches?(actual_value)
        block_required!
      end

      def does_not_match?(actual_value)
        block_required!
      end

      def does_not_match?(&block)
        !matches?(&block)
      end

      def print_failure_message(printer : Formatters::Printer, actual_value) : Nil
        block_required!
      end

      def failure_message(actual_value)
        block_required!
      end

      def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil
        block_required!
      end

      def negated_failure_message(actual_value)
        block_required!
      end
    end
  end
end
