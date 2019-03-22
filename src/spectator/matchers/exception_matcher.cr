require "./value_matcher"

module Spectator::Matchers
  # Matcher that tests whether an exception is raised.
  struct ExceptionMatcher(ExceptionType, ExpectedType) < ValueMatcher(ExpectedType)
    # Determines whether the matcher is satisfied with the value given to it.
    private def match?(exception)
      exception.is_a?(ExceptionType) && (expected.nil? || expected === exception.message)
    end

    # Runs a block of code and returns the exception it threw.
    # If no exception was thrown, *nil* is returned.
    private def capture_exception
      exception = nil
      begin
        yield
      rescue ex
        exception = ex
      end
      exception
    end

    # Determines whether the matcher is satisfied with the partial given to it.
    # `MatchData` is returned that contains information about the match.
    def match(partial)
      exception = capture_exception { partial.actual }
      matched = match?(exception)
      if exception.nil?
        MatchData.new(ExceptionType, matched, ExpectedActual.new(expected, label, exception, partial.label))
      else
        values = ExpectedActual.new(expected, label, exception, partial.label)
        if expected.nil?
          MatchData.new(ExceptionType, matched, values)
        else
          MessageMatchData.new(ExceptionType, matched, values)
        end
      end
    end

    # Creates a new exception matcher with no message check.
    def initialize
      super(nil, ExceptionType.to_s)
    end

    # Creates a new exception matcher with a message check.
    def initialize(expected : ExpectedType, label : String)
      super(expected, label)
    end

    # Creates a new exception matcher with no message check.
    def self.create(exception_type : T.class, label : String) forall T
      ExceptionMatcher(T, Nil).new
    end

    # Creates a new exception matcher with a message check.
    def self.create(expected, label : String)
      ExceptionMatcher(Exception, typeof(expected)).new(expected, label)
    end

    # Match data specific to this matcher.
    private struct MatchData(ExceptionType, ExpectedType, ActualType) < MatchData
      # Creates the match data.
      def initialize(t : ExceptionType.class, matched, @values : ExpectedActual(ExpectedType, ActualType))
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          "expected type": NegatableMatchDataValue.new(ExceptionType),
          "actual type":   @values.actual.class,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} raises #{ExceptionType}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not raise #{ExceptionType}"
      end
    end

    # Match data specific to this matcher with an expected message.
    private struct MessageMatchData(ExceptionType, ExpectedType) < ::Spectator::Matchers::MatchData
      # Creates the match data.
      def initialize(t : ExceptionType.class, matched, @values : ExpectedActual(ExpectedType, Exception))
        super(matched)
      end

      # Information about the match.
      def named_tuple
        {
          "expected type":    NegatableMatchDataValue.new(ExceptionType),
          "actual type":      @values.actual.class,
          "expected message": NegatableMatchDataValue.new(@values.expected),
          "actual message":   @values.actual.message,
        }
      end

      # Describes the condition that satisfies the matcher.
      # This is informational and displayed to the end-user.
      def message
        "#{@values.actual_label} raises #{ExceptionType} with message #{@values.expected_label}"
      end

      # Describes the condition that won't satsify the matcher.
      # This is informational and displayed to the end-user.
      def negated_message
        "#{@values.actual_label} does not raise #{ExceptionType} with message #{@values.expected_label}"
      end
    end
  end
end
