require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether an expression changed by an amount.
  struct ChangeRelativeMatcher(ExpressionType) < Matcher
    # The expression that is expected to (not) change.
    private getter expression

    # Creates a new change matcher.
    def initialize(@expression : Block(ExpressionType), @relativity : String,
                   &evaluator : ExpressionType, ExpressionType -> Bool)
      @evaluator = evaluator
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label} #{@relativity}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      before, after = change(actual)
      if before == after
        FailedMatchData.new(match_data_description(actual), "#{actual.label} did not change #{expression.label}",
          before: before.inspect,
          after: after.inspect
        )
      elsif @evaluator.call(before, after)
        SuccessfulMatchData.new(match_data_description(actual))
      else
        FailedMatchData.new(match_data_description(actual), "#{actual.label} did not change #{expression.label} #{@relativity}",
          before: before.inspect,
          after: after.inspect
        )
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      {% raise "The `expect { }.to_not change { }.by_...()` syntax is not supported (ambiguous)." %}
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
