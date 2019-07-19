require "./change_from_matcher"
require "./change_to_matcher"
require "./matcher"

module Spectator::Matchers
  # Matcher that tests whether an expression changed.
  struct ChangeMatcher(ExpressionType) < Matcher
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
      same = before == after    # Did the value change?
      MatchData.new(!same, before, after, partial.label, label)
    end

    # Creates a new change matcher with a custom label.
    def initialize(@label, &expression : -> ExpressionType)
      @expression = expression
    end

    # Creates a new change matcher.
    def initialize(&expression : -> ExpressionType)
      @label = expression.to_s
      @expression = expression
    end

    # Specifies what the initial value of the expression must be.
    def from(value : T) forall T
      ChangeFromMatcher.new(label, value, &@expression)
    end

    # Specifies what the resulting value of the expression must be.
    def to(value : T) forall T
      ChangeToMatcher.new(label, value, &@expression)
    end

    # Match data specific to this matcher.
    private struct MatchData(ExpressionType) < MatchData
      # Creates the match data.
      def initialize(matched, @before : ExpressionType, @after : ExpressionType,
        @action_label : String, @expression_label : String)
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          before: @before,
          after:  @after
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@action_label} changes #{@expression_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@action_label} does not change #{@expression_label}"
      end
    end
  end
end
