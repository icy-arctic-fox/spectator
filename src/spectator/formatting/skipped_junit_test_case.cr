require "./junit_test_case"

module Spectator::Formatting
  # JUnit test case for a pending result.
  private class SkippedJUnitTestCase < JUnitTestCase
    # Result for this test case.
    private getter result

    # Creates the JUnit test case.
    def initialize(@result : PendingResult)
    end

    # Status string specific to the result type.
    private def status : String
      "TODO"
    end

    # Adds the skipped tag to the XML block.
    private def content(xml)
      super
      xml.element("skipped")
    end
  end
end
