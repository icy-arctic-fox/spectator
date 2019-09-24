require "./finished_junit_test_case"

module Spectator::Formatting
  # JUnit test case for a failed result.
  private class FailureJUnitTestCase < FinishedJUnitTestCase
    # Result for this test case.
    private getter result

    # Creates the JUnit test case.
    def initialize(@result : FailedResult)
    end

    # Status string specific to the result type.
    private def status : String
      "FAIL"
    end

    # Adds the failed expectations to the XML block.
    private def content(xml)
      super
      @result.expectations.each_unsatisfied do |expectation|
        xml.element("failure", message: expectation.failure_message) do
          expectation_values(expectation.values, xml)
        end
      end
    end

    # Adds the expectation values to the failure block.
    private def expectation_values(labeled_values, xml)
      labeled_values.each do |entry|
        label = entry.first
        value = entry.last
        xml.text("#{label}: #{value}\n")
      end
    end
  end
end
