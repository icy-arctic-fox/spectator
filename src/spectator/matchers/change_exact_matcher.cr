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
    def initialize(@expression : Block(ExpressionType), @expected_before : FromType, @expected_after : ToType)
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      "changes #{expression.label} from #{expected_before.inspect} to #{expected_after.inspect}"
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      before = expression.value
      before_inspect = before.inspect

      if expected_before == before
        actual.value # Trigger block that might cause a change.
        after = expression.value
        after_inspect = after.inspect

        if expected_after == after
          SuccessfulMatchData.new(match_data_description(actual))
        elsif before == after
          FailedMatchData.new(match_data_description(actual), "#{actual.label} did not change #{expression.label}",
            before: before_inspect,
            after: after_inspect
          )
        else
          FailedMatchData.new(match_data_description(actual), "#{actual.label} did not change #{expression.label} to #{expected_after.inspect}",
            before: before_inspect,
            after: after_inspect,
            expected: expected_after.inspect
          )
        end
      else
        FailedMatchData.new(match_data_description(actual), "#{expression.label} was not initially #{expected_before.inspect}",
          expected: expected_before.inspect,
          actual: before_inspect,
        )
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      before = expression.value
      before_inspect = before.inspect

      if expected_before == before
        actual.value # Trigger block that might cause a change.
        after = expression.value
        after_inspect = after.inspect

        if expected_after == after
          FailedMatchData.new(match_data_description(actual), "#{actual.label} changed #{expression.label} from #{expected_before.inspect} to #{expected_after.inspect}",
            before: before_inspect,
            after: after_inspect
          )
        else
          SuccessfulMatchData.new(match_data_description(actual))
        end
      else
        FailedMatchData.new(match_data_description(actual), "#{expression.label} was not initially #{expected_before.inspect}",
          expected: expected_before.inspect,
          actual: before_inspect,
        )
      end
    end
  end
end
