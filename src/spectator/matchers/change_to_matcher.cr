require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether an expression changed to a specific value.
  struct ChangeToMatcher(ExpressionType, ToType) < Matcher
    # Textual representation of what the matcher expects.
    # This shouldn't be used in the conditional logic,
    # but for verbose output to help the end-user.
    getter label : String

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      before = @expression.call # Retrieve the expression's initial value.
      partial.actual            # Invoke action that might change the expression's value.
      after = @expression.call  # Retrieve the expression's value again.
      if @expected_after != after
        # Resulting value isn't what was expected.
        ResultingMatchData.new(before, @expected_after, after, partial.label, label)
      else
        # Check if the expression's value changed.
        same = before == after
        ChangeMatchData.new(!same, before, @expected_after, after, partial.label, label)
      end
    end

    # Creates a new change matcher with a custom label.
    def initialize(@label, @expected_after : ToType, &expression : -> ExpressionType)
      @expression = expression
    end

    # Creates a new change matcher.
    def initialize(@expected_after : ToType, &expression : -> ExpressionType)
      @label = expression.to_s
      @expression = expression
    end

    # Match data for when the resulting value isn't the expected value.
    private struct ResultingMatchData(ExpressionType, ToType) < MatchData
      # Creates the match data.
      def initialize(@before : ExpressionType, @expected_after : ToType, @actual_after : ExpressionType,
                     @action_label : String, @expression_label : String)
        super(false)
      end

      # Do not allow negation of this match data.
      def override?
        true
      end

      # Information about the match.
      def named_tuple
        {
          "expected before": NegatableMatchDataValue.new(@expected_after, true),
          "actual before":   @before,
          "expected after":  @expected_after,
          "actual after":    @actual_after,
        }
      end

      # This is informational and displayed to the end-user.
      def message
        "#{@expression_label} changes to #{@expected_after}"
      end

      # This is informational and displayed to the end-user.
      def negated_message
        "#{@expression_label} did not change to #{@expected_after}"
      end
    end

    private struct ChangeMatchData(ExpressionType, ToType) < MatchData
      # Creates the match data.
      def initialize(matched, @before : ToType, @expected_after : ToType, @actual_after : ExpressionType,
                     @action_label : String, @expression_label : String)
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          "expected before": NegatableMatchDataValue.new(@expected_after, true),
          "actual before":   @before,
          "expected after":  @expected_after,
          "actual after":    @actual_after,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@action_label} changed #{@expression_label} to #{@expected_after}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@action_label} did not change #{@expression_label} to #{@expected_after}"
      end
    end
  end
end
