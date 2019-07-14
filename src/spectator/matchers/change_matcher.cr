require "./change_from_matcher"
require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether an expression changed.
  struct ChangeMatcher(ExpressionType) < ValueMatcher(ExpressionType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(after)
      expected != after
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      partial.actual # Invoke action that might change the expression's value.
      after = @expression.call # Retrieve the expression's value.
      MatchData.new(match?(after), expected, after, partial.label, label)
    end

    # Creates a new change matcher with a custom label.
    def initialize(label : String, &expression : -> ExpressionType)
      super(yield, label)
      @expression = expression
    end

    # Creates a new change matcher.
    def initialize(&expression : -> ExpressionType)
      super(yield, expression.to_s)
      @expression = expression
    end

    # Specifies what the initial value of the expression must be.
    def from(value : T) forall T
      ChangeFromMatcher.new(label, value, expected, &@expression)
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
