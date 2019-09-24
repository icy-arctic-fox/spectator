require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether an expression changed from and to specific values.
  struct ChangeExactMatcher(ExpressionType, FromType, ToType) < Matcher
    # The expression that is expected to (not) change.
    private getter expression

    # The expected value of the expression before the change.
    private getter expected_before

    # The expected value of the expression after the change.
    private getter expected_after

    # Creates a new change matcher.
    def initialize(@expression : TestBlock(ExpressionType), @expected_before : FromType, @expected_after : ToType)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label} from #{expected_before.inspect} to #{expected_after.inspect}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      before, after = change(actual)
      if expected_before == before
        if before == after
          FailedMatchData.new("#{actual.label} did not change #{expression.label}",
            before: before.inspect,
            after: after.inspect
          )
        elsif expected_after == after
          SuccessfulMatchData.new
        else
          FailedMatchData.new("#{actual.label} did not change #{expression.label} to #{expected_after.inspect}",
            before: before.inspect,
            after: after.inspect,
            expected: expected_after.inspect
          )
        end
      else
        FailedMatchData.new("#{expression.label} was not initially #{expected_before.inspect}",
          expected: expected_before.inspect,
          actual: before.inspect,
        )
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      before, after = change(actual)
      if expected_before == before
        if expected_after == after
          FailedMatchData.new("#{actual.label} changed #{expression.label} from #{expected_before.inspect} to #{expected_after.inspect}",
            before: before.inspect,
            after: after.inspect
          )
        else
          SuccessfulMatchData.new
        end
      else
        FailedMatchData.new("#{expression.label} was not initially #{expected_before.inspect}",
          expected: expected_before.inspect,
          actual: before.inspect,
        )
      end
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
