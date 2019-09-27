module Spectator::Formatting
  # JUnit test case for a successful result.
  private class SuccessfulJUnitTestCase < FinishedJUnitTestCase
    # Result for this test case.
    private getter result

    # Creates the JUnit test case.
    def initialize(@result : SuccessfulResult)
    end

    # Status string specific to the result type.
    private def status : String
      "PASS"
    end
  end
end
