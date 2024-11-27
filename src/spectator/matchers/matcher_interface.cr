require "../formatters/printer"
require "./match_failure"

module Spectator::Matchers
  module Matcher
    abstract def description

    abstract def match(actual_value) : MatchFailure?

    abstract def match_negated(actual_value) : MatchFailure?

    abstract def matches?(actual_value)

    abstract def matches?(&)

    abstract def does_not_match?(actual_value)

    abstract def does_not_match?(&)

    abstract def failure_message(actual_value)

    abstract def failure_message(&)

    abstract def print_failure_message(printer : Formatters::Printer, actual_value) : Nil

    abstract def print_failure_message(printer : Formatters::Printer, &) : Nil

    abstract def negated_failure_message(actual_value)

    abstract def negated_failure_message(&)

    abstract def print_negated_failure_message(printer : Formatters::Printer, actual_value) : Nil

    abstract def print_negated_failure_message(printer : Formatters::Printer, &) : Nil
  end
end
