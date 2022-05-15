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
    def initialize(@expression : Block(ExpressionType), @expected : FromType)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label} from #{expected}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      before = expression.value
      before_inspect = before.inspect

      if expected != before
        return FailedMatchData.new(match_data_description(actual), "#{expression.label} was not initially #{expected}",
          expected: expected.inspect,
          actual: before_inspect,
        )
      end

      actual.value # Trigger block that might change the expression.
      after = expression.value
      after_inspect = after.inspect

      if expected == after
        FailedMatchData.new(match_data_description(actual), "#{actual.label} did not change #{expression.label} from #{expected}",
          before: before_inspect,
          after: after_inspect,
          expected: "Not #{expected.inspect}"
        )
      else
        SuccessfulMatchData.new(match_data_description(actual))
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      before = expression.value
      before_inspect = before.inspect

      if expected != before
        return FailedMatchData.new(match_data_description(actual), "#{expression.label} was not initially #{expected}",
          expected: expected.inspect,
          actual: before_inspect
        )
      end

      actual.value # Trigger block that might change the expression.
      after = expression.value
      after_inspect = after.inspect

      if expected == after
        SuccessfulMatchData.new(match_data_description(actual))
      else
        FailedMatchData.new(match_data_description(actual), "#{actual.label} changed #{expression.label} from #{expected}",
          before: before_inspect,
          after: after_inspect,
          expected: expected.inspect
        )
      end
    end

    # Specifies what the resulting value of the expression must be.
    def to(value)
      ChangeExactMatcher.new(@expression, @expected, value)
    end

    # Specifies what the resulting value of the expression should change by.
    def by(amount)
      ChangeExactMatcher.new(@expression, @expected, @expected + value)
    end
  end
end
