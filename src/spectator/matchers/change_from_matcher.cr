require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether an expression changed from a specific value.
  struct ChangeFromMatcher(ExpressionType, FromType) < Matcher
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
      if @expected_before != before
        # Initial value isn't what was expected.
        InitialMatchData.new(@expected_before, before, after, partial.label, label)
      else
        # Check if the expression's value changed.
        same = before == after
        ChangeMatchData.new(!same, @expected_before, before, after, partial.label, label)
      end
    end

    # Creates a new change matcher with a custom label.
    def initialize(@label, @expected_before : FromType, &expression : -> ExpressionType)
      @expression = expression
    end

    # Creates a new change matcher.
    def initialize(@expected_before : FromType, &expression : -> ExpressionType)
      @label = expression.to_s
      @expression = expression
    end

    # Match data for when the initial value isn't the expected value.
    private struct InitialMatchData(ExpressionType, FromType) < MatchData
      # Creates the match data.
      def initialize(@expected_before : FromType, @actual_before : ExpressionType, @after : ExpressionType,
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
          "expected before": @expected_before,
          "actual before":   @actual_before,
          "expected after":  NegatableMatchDataValue.new(@expected_before, true),
          "actual after":    @after,
        }
      end

      # This is informational and displayed to the end-user.
      def message
        "#{@expression_label} is initially #{@expected_before}"
      end

      # This is informational and displayed to the end-user.
      def negated_message
        "#{@expression_label} is not initially #{@expected_before}"
      end
    end

    private struct ChangeMatchData(ExpressionType, FromType) < MatchData
      # Creates the match data.
      def initialize(matched, @expected_before : FromType, @actual_before : ExpressionType,
                     @after : ExpressionType, @action_label : String, @expression_label : String)
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          "expected before": @expected_before,
          "actual before":   @actual_before,
          "expected after":  NegatableMatchDataValue.new(@expected_before, true),
          "actual after":    @after,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@action_label} changed #{@expression_label} from #{@expected_before}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@action_label} did not change #{@expression_label} from #{@expected_before}"
      end
    end
  end
end
