require "../test_value"
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
    def description
      "all #{matcher.description}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      found = test_values(actual).each do |element|
        match_data = matcher.match(element)
        break match_data unless match_data.matched?
      end
      found ? found : SuccessfulMatchData.new
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      raise NotImplementedError.new("AllMatcher#negated_match")
    end

    # Maps all values in the test collection to their own test values.
    # Each value is given their own label,
    # which is the original label with an index appended.
    private def test_values(actual)
      label_prefix = actual.label
      actual.value.map_with_index do |value, index|
        label = "#{label_prefix}[#{index}]"
        TestValue.new(value, label)
      end
    end
  end
end
