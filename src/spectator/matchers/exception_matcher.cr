require "../value"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether an exception is raised.
  struct ExceptionMatcher(ExceptionType, ExpectedType) < Matcher
    # Expected value and label.
    private getter expected

    # Creates the matcher with no expectation of the message.
    def initialize
      @expected = Value.new(nil, ExceptionType.to_s)
    end

    # Creates the matcher with an expected message.
    def initialize(@expected : Value(ExpectedType))
    end

    # Short text about the matcher's purpose.
    # This explains what condition satisfies the matcher.
    # The description is used when the one-liner syntax is used.
    def description : String
      if (message = @expected)
        "raises #{ExceptionType} with message #{message}"
      else
        "raises #{ExceptionType}"
      end
    end

    # Actually performs the test against the expression.
    def match(actual : Expression(T)) : MatchData forall T
      exception = capture_exception { actual.value }
      if exception.nil?
        FailedMatchData.new(match_data_description(actual), "#{actual.label} did not raise", expected: ExceptionType.inspect)
      else
        if exception.is_a?(ExceptionType)
          if (value = expected.value).nil?
            SuccessfulMatchData.new(match_data_description(actual))
          else
            if value === exception.message
              SuccessfulMatchData.new(match_data_description(actual))
            else
              FailedMatchData.new(match_data_description(actual), "#{actual.label} raised #{exception.class}, but the message is not #{expected.label}",
                "expected type": ExceptionType.inspect,
                "actual type": exception.class.inspect,
                "expected message": value.inspect,
                "actual message": exception.message.to_s
              )
            end
          end
        else
          FailedMatchData.new(match_data_description(actual), "#{actual.label} did not raise #{ExceptionType}",
            expected: ExceptionType.inspect,
            actual: exception.class.inspect
          )
        end
      end
    end

    # Performs the test against the expression, but inverted.
    # A successful match with `#match` should normally fail for this method, and vice-versa.
    def negated_match(actual : Expression(T)) : MatchData forall T
      exception = capture_exception { actual.value }
      if exception.nil?
        SuccessfulMatchData.new(match_data_description(actual))
      else
        if exception.is_a?(ExceptionType)
          if (value = expected.value).nil?
            FailedMatchData.new(match_data_description(actual), "#{actual.label} raised #{exception.class}",
              expected: "Not #{ExceptionType}",
              actual: exception.class.inspect
            )
          else
            if value === exception.message
              FailedMatchData.new(match_data_description(actual), "#{actual.label} raised #{exception.class} with message matching #{expected.label}",
                "expected type": ExceptionType.inspect,
                "actual type": exception.class.inspect,
                "expected message": value.inspect,
                "actual message": exception.message.to_s
              )
            else
              SuccessfulMatchData.new(match_data_description(actual))
            end
          end
        else
          SuccessfulMatchData.new(match_data_description(actual))
        end
      end
    end

    def with_message(message : T) forall T
      value = Value.new(message)
      ExceptionMatcher(ExceptionType, T).new(value)
    end

    # Runs a block of code and returns the exception it threw.
    # If no exception was thrown, *nil* is returned.
    private def capture_exception(&)
      exception = nil
      begin
        yield
      rescue ex
        exception = ex
      end
      exception
    end

    # Creates a new exception matcher with no message check.
    def self.create(exception_type : T.class, label : String) forall T
      ExceptionMatcher(T, Nil).new
    end

    # Creates a new exception matcher with a message check.
    def self.create(value, label : String)
      expected = Value.new(value, label)
      ExceptionMatcher(Exception, typeof(value)).new(expected)
    end

    # Creates a new exception matcher with a type and message check.
    def self.create(exception_type : T.class, value, label : String) forall T
      expected = Value.new(value, label)
      ExceptionMatcher(T, typeof(value)).new(expected)
    end
  end
end
