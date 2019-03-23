module Spectator::Formatting
  # Selector for creating a JUnit test case based on a result.
  private module JUnitTestCase
    extend self

    # Creates a successful JUnit test case.
    def success(result)
      SuccessfulJUnitTestCase.new(result.as(SuccessfulResult))
    end

    # Creates a failure JUnit test case.
    def failure(result)
      FailureJUnitTestCase.new(result.as(FailedResult))
    end

    # Creates an error JUnit test case.
    def error(result)
      ErrorJUnitTestCase.new(result.as(ErroredResult))
    end

    # Creates a skipped JUnit test case.
    def pending(result)
      SkippedJUnitTestCase.new(result.as(PendingResult))
    end
  end
end
