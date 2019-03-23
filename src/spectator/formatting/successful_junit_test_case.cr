module Spectator::Formatting
  # JUnit test case for a successful result.
  private class SuccessfulJUnitTestCase < FinishedJUnitTestCase
    # Result for this test case.
    private getter result

    # Creates the JUnit test case.
    def initialize(@result : SuccessfulResult)
    end
  end
end
