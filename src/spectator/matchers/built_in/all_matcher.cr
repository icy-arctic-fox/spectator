require "../formatting"
require "../match_failure"
require "../matcher"

module Spectator::Matchers::BuiltIn
  class AllMatcher(T)
    include Formatting

    def initialize(@matcher : T)
    end

    def match(actual_value : Enumerable) : MatchFailure?
      failures = actual_value.map do |value|
        Matcher.match(@matcher, value)
      end
      return unless failures.any?

      MatchFailure.new do |printer|
        printer << "Expected all of: " << description_of(actual_value) << EOL
        printer << "to " << description_of(@matcher) << EOL
        print_failures(failures, printer)
      end
    end

    private def print_failures(failures, printer)
      failures.each_with_index do |failure, index|
        next unless failure
        printer.label("[#{index}]") do
          failure.format(printer)
        end
      end
    end
  end
end
