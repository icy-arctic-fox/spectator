require "./change_exact_matcher"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether an expression changed from a specific value.
  struct ChangeFromMatcher(ExpressionType, FromType) < Matcher
    # The expression that is expected to (not) change.
    private getter expression

    # The expected value of the expression before the change.
    private getter expected

    # Creates a new change matcher.
    def initialize(@expression : TestBlock(ExpressionType), @expected : FromType)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label} from #{expected}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      before, after = change(actual)
      if expected != before
        FailedMatchData.new("#{expression.label} was not initially #{expected}",
          expected: expected.inspect,
          actual: before.inspect,
        )
      elsif before == after
        FailedMatchData.new("#{actual.label} did not change #{expression.label} from #{expected}",
          before: before.inspect,
          after: after.inspect,
          expected: "Not #{expected.inspect}"
        )
      else
        SuccessfulMatchData.new
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      before, after = change(actual)
      if expected != before
        FailedMatchData.new("#{expression.label} was not initially #{expected}",
          expected: expected.inspect,
          actual: before.inspect
        )
      elsif before == after
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} changed #{expression.label} from #{expected}",
          before: before.inspect,
          after: after.inspect,
          expected: expected.inspect
        )
      end
    end

    # Specifies what the resulting value of the expression must be.
    def to(value : T) forall T
      ChangeExactMatcher.new(@expression, @expected, value)
    end

    # Specifies what the resulting value of the expression should change by.
    def by(amount : T) forall T
      ChangeExactMatcher.new(@expression, @expected, @expected + value)
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
