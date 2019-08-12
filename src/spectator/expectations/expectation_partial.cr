require "../matchers/match_data"
require "../source"
require "../test_expression"

module Spectator::Expectations
  # Stores part of an expectation (obviously).
  # The part of the expectation this type covers is the actual value and source.
  # This can also cover a block's behavior.
  struct ExpectationPartial(T)
    # The actual value being tested.
    # This also contains its label.
    getter actual : TestExpression(T)

    # Location where this expectation was defined.
    getter source : Source

    # Creates the partial.
    def initialize(@actual : TestExpression(T), @source : Source)
    end

    # Asserts that some criteria defined by the matcher is satisfied.
    def to(matcher) : Nil
      match_data = matcher.match(@actual)
      report(match_data)
    end

    # Asserts that some criteria defined by the matcher is not satisfied.
    # This is effectively the opposite of `#to`.
    def to_not(matcher) : Nil
      match_data = matcher.negated_match(@actual)
      report(match_data)
    end

    # ditto
    @[AlwaysInline]
    def not_to(matcher) : Nil
      to_not(matcher)
    end

    # Reports an expectation to the current harness.
    private def report(match_data : Matchers::MatchData)
      expectation = Expectation.new(match_data, @source)
      Internals::Harness.current.report_expectation(expectation)
    end
  end
end
