require "./match_data"

module Spectator::Matchers
  # Common base class for all expectation conditions.
  # A matcher looks at something produced by the SUT
  # and evaluates whether it is correct or not.
  abstract struct Matcher
    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    # ```
    # it { is_expected.to do_something }
    # ```
    # The phrasing should be such that it reads "it ___."
    abstract def description : String

    abstract def match(actual : TestExpression(T)) : MatchData forall T

    abstract def negated_match(actual : TestExpression(T)) : MatchData forall T
  end
end
