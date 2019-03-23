module Spectator::Formatting
  private struct FailureJUnitTestCase
    def initialize(@result : FailedResult)
    end

    def to_xml(xml : ::XML::Builder)
      xml.element("testcase",
        name: @result.example,
        status: @result,
        time: @result.elapsed.total_seconds,
        classname: classname,
        assertions: @result.expectations.size) do
        @result.expectations.each_unsatisfied do |expectation|
          xml.element("failure", message: expectation.actual_message) do
            # TODO: Add values as text to block.
          end
        end
      end
    end

    private def classname
      "TODO"
    end
  end
end
