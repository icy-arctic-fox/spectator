require "./change_exact_matcher"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether an expression changed to a specific value.
  struct ChangeToMatcher(ExpressionType, ToType) < Matcher
    # The expression that is expected to (not) change.
    private getter expression

    # The expected value of the expression after the change.
    private getter expected

    # Creates a new change matcher.
    def initialize(@expression : TestBlock(ExpressionType), @expected : ToType)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label} to #{expected}"
    end

    # Actually performs the test against the expression.
    def match(actual : TestExpression(T)) : MatchData forall T
      before, after = change(actual)
      if before == after
        FailedMatchData.new("#{actual.label} did not change #{expression.label}",
          before: before.inspect,
          after: after.inspect,
          expected: expected.inspect
        )
      elsif expected == after
        SuccessfulMatchData.new
      else
        FailedMatchData.new("#{actual.label} did not change #{expression.label} to #{expected}",
          before: before.inspect,
          after: after.inspect,
          expected: expected.inspect
        )
      end
    end

    # Negated matching for this matcher is not supported.
    # Attempting to call this method will result in a compilation error.
    #
    # This syntax has a logical problem.
    # "The action does not change the expression to some value."
    # Is it a failure if the value is not changed,
    # but it is the expected value?
    #
    # RSpec doesn't support this syntax either.
    def negated_match(actual : TestExpression(T)) : MatchData forall T
      {% raise "The `expect { }.to_not change { }.to()` syntax is not supported (ambiguous)." %}
    end

    # Specifies what the initial value of the expression must be.
    def from(value : T) forall T
      ChangeExactMatcher.new(@expression, value, @expected)
    end

    # Specifies how much the initial value should change by.
    def by(amount : T) forall T
      ChangeExactMatcher.new(@expression, @expected - amount, @expected)
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
