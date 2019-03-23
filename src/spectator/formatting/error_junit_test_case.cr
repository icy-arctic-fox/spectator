require "./failure_junit_test_case"

module Spectator::Formatting
  # JUnit test case for a errored result.
  private class ErrorJUnitTestCase < FailureJUnitTestCase
    # Result for this test case.
    private getter result

    # Creates the JUnit test case.
    def initialize(@result : ErroredResult)
    end

    # Adds the exception to the XML block.
    private def content(xml)
      xml.element("error", message: @result.error.message, type: @result.error.class)
      super
    end
  end
end
