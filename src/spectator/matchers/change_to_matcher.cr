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
    def initialize(@expression : Block(ExpressionType), @expected : ToType)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label} to #{expected}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      before = expression.value
      before_inspect = before.inspect

      if expected == before
        return FailedMatchData.new(match_data_description(actual), "#{expression.label} was already #{expected}",
          before: before_inspect,
          expected: "Not #{expected.inspect}"
        )
      end

      actual.value # Trigger block that could change the expression.
      after = expression.value
      after_inspect = after.inspect

      if expected == after
        SuccessfulMatchData.new(match_data_description(actual))
      else
        FailedMatchData.new(match_data_description(actual), "#{actual.label} did not change #{expression.label} to #{expected}",
          before: before_inspect,
          after: after_inspect,
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
    def negated_match(actual : Expression(T)) : MatchData forall T
      {% raise "The `expect { }.to_not change { }.to()` syntax is not supported (ambiguous)." %}
    end

    # Specifies what the initial value of the expression must be.
    def from(value)
      ChangeExactMatcher.new(@expression, value, @expected)
    end

    # Specifies how much the initial value should change by.
    def by(amount)
      ChangeExactMatcher.new(@expression, @expected - amount, @expected)
    end
  end
end
