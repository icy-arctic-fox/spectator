require "../test_value"
require "./failed_match_data"
require "./matcher"
require "./successful_match_data"

module Spectator::Matchers
  # Matcher that tests whether an exception is raised.
  struct ExceptionMatcher(ExceptionType, ExpectedType) < Matcher
    private getter expected

    def initialize
      @expected = TestValue.new(nil, ExceptionType.to_s)
    end

    def initialize(@expected : TestValue(ExpectedType))
    end

    def match(actual)
      exception = capture_exception { actual.value }
      case exception
      when Nil
        FailedMatchData.new("#{actual.label} did not raise", expected: ExpectedType.inspect)
      when ExceptionType
        if expected.value.nil? || expected.value === exception.message
          SuccessfulMatchData.new
        else
          FailedMatchData.new("#{actual.label} raised #{ExpectedType}, but the message is not #{expected.label}",
            "expected type": ExceptionType.inspect,
            "actual type": exception.class.inspect,
            "expected message": expected.value.inspect,
            "actual message": exception.message
          )
        end
      else
        FailedMatchData.new("#{actual.label} did not raise #{ExpectedType}",
          expected: ExpectedType.inspect,
          actual: exception.class.inspect
        )
      end
    end

    def negated_match(actual)
      exception = capture_exception { actual.value }
      case exception
      when Nil
        SuccessfulMatchData.new
      when ExceptionType
        if expected.value.nil?
          FailedMatchData.new("#{actual.label} raised #{ExpectedType}")
        elsif expected.value === exception.message
          FailedMatchData.new("#{actual.label} raised #{ExpectedType} with message matching #{expected.label}",
            "expected type": ExceptionType.inspect,
            "actual type": exception.class.inspect,
            "expected message": expected.value.inspect,
            "actual message": exception.message
          )
        else
          SuccessfulMatchData.new
        end
      else
        SuccessfulMatchData.new
      end
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

    # Creates a new exception matcher with no message check.
    def self.create(exception_type : T.class, label : String) forall T
      ExceptionMatcher(T, Nil).new
    end

    # Creates a new exception matcher with a message check.
    def self.create(value, label : String)
      expected = TestValue.new(value, label)
      ExceptionMatcher(Exception, typeof(value)).new(expected)
    end

    # Creates a new exception matcher with a type and message check.
    def self.create(exception_type : T.class, value, label : String) forall T
      expected = TestValue.new(value, label)
      ExceptionMatcher(T, typeof(value)).new(expected)
    end
  end
end
