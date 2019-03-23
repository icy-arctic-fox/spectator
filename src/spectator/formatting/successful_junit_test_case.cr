module Spectator::Formatting
  private struct SuccessfulJUnitTestCase
    def initialize(@result : SuccessfulResult)
    end

    def to_xml(xml : ::XML::Builder)
      xml.element("testcase",
        name: @result.example,
        status: @result,
        time: @result.elapsed.total_seconds,
        classname: classname,
        assertions: @result.expectations.size)
    end

    private def classname
      "TODO"
    end
  end
end
