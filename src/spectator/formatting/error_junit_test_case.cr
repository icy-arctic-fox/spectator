module Spectator::Formatting
  private struct ErrorJUnitTestCase
    def initialize(@result : ErroredResult)
    end

    def to_xml(xml : ::XML::Builder)
      xml.element("testcase",
        name: @result.example,
        status: @result,
        time: @result.elapsed.total_seconds,
        classname: classname,
        assertions: @result.expectations.size) do
        xml.element("error", message: @result.error.message, type: @result.error.class)
        @result.expectations.each_unsatisfied do |expectation|
          xml.element("failure", message: expectation.actual_message) do
            # TODO: Add values as text to this block.
          end
        end
      end
    end

    private def classname
      "TODO"
    end
  end
end
