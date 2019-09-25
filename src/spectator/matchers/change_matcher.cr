require "./change_from_matcher"
require "./change_to_matcher"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether an expression changed.
  struct ChangeMatcher(ExpressionType) < Matcher
    # The expression that is expected to (not) change.
    private getter expression

    # Creates a new change matcher.
    def initialize(@expression : TestBlock(ExpressionType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      before, after = change(actual)
      if before == after
        FailedMatchData.new("#{actual.label} did not change #{expression.label}",
          before: before.inspect,
          after: after.inspect
        )
      else
        SuccessfulMatchData.new
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      before, after = change(actual)
      if before == after
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} changed #{expression.label}",
          before: before.inspect,
          after: after.inspect
        )
      end
    end

    # Specifies what the initial value of the expression must be.
    def from(value : T) forall T
      ChangeFromMatcher.new(@expression, value)
    end

    # Specifies what the resulting value of the expression must be.
    def to(value : T) forall T
      ChangeToMatcher.new(@expression, value)
    end

    # Specifies that t he resulting value must be some amount different.
    def by(amount : T) forall T
      ChangeRelativeMatcher.new(@expression, "by #{amount}") { |before, after| amount == after - before }
    end

    # Specifies that the resulting value must be at least some amount different.
    def by_at_least(minimum : T) forall T
      ChangeRelativeMatcher.new(@expression, "by at least #{minimum}") { |before, after| minimum <= after - before }
    end

    # Specifies that the resulting value must be at most some amount different.
    def by_at_most(maximum : T) forall T
      ChangeRelativeMatcher.new(@expression, "by at most #{maximum}") { |before, after| maximum >= after - before }
    end

    # Performs the change and reports the before and after values.
    private def change(actual)
      before = expression.value # Retrieve the expression's initial value.
      actual.value              # Invoke action that might change the expression's value.
      after = expression.value  # Retrieve the expression's value again.

      {before, after}
    end
  end
end
