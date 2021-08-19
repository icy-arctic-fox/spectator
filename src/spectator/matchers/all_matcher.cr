require "../value"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that checks if all elements of a collection apply to some other matcher.
  struct AllMatcher(TMatcher) < Matcher
    # Other matcher that all elements must match successfully.
    private getter matcher

    # Creates the matcher with an expected successful matcher.
    def initialize(@matcher : TMatcher)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "all #{matcher.description}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      found = values(actual).each do |element|
        match_data = matcher.match(element)
        break match_data unless match_data.matched?
      end
      found || SuccessfulMatchData.new(match_data_description(actual))
    end

    # Negated matching for this matcher is not supported.
    # Attempting to call this method will result in a compilation error.
    #
    # This syntax has a logical problem.
    # "All values do not satisfy some condition."
    # Does this mean that all values don't satisfy the matcher?
    # What if only one doesn't?
    # What if the collection is empty?
    #
    # RSpec doesn't support this syntax either.
    def negated_match(actual : Expression(T)) : MatchData forall T
      {% raise "The `expect { }.to_not all()` syntax is not supported (ambiguous)." %}
    end

    # Maps all values in the test collection to their own test values.
    # Each value is given their own label,
    # which is the original label with an index appended.
    private def values(actual)
      label_prefix = actual.label
      actual.value.map_with_index do |value, index|
        label = "#{label_prefix}[#{index}]"
        Value.new(value, label)
      end
    end
  end
end
