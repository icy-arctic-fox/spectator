module Spectator::Formatting
  private struct SkippedJUnitTestCase
    def initialize(@result : PendingResult)
    end

    def to_xml(xml : ::XML::Builder)
      xml.element("testcase",
        name: @result.example,
        status: @result,
        classname: classname) do
        xml.element("skipped")
      end
    end

    private def classname
      "TODO"
    end
  end
end
