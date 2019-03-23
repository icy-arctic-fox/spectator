require "./junit_test_case"

module Spectator::Formatting
  # Commonalities of all test cases that ran (success or failure).
  private abstract class FinishedJUnitTestCase < JUnitTestCase
    # Produces the test case XML element.
    def to_xml(xml : ::XML::Builder)
      xml.element("testcase", **full_attributes) do
        content(xml)
      end
    end

    # Attributes that go in the "testcase" XML element.
    private def full_attributes
      attributes.merge(
        time: result.elapsed.total_seconds,
        assertions: result.expectations.size
      )
    end
  end
end
