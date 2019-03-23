module Spectator::Formatting
  # Base type for all JUnit test case results.
  private abstract class JUnitTestCase
    # Produces the test case XML element.
    def to_xml(xml : ::XML::Builder)
      xml.element("testcase", **attributes) do
        content(xml)
      end
    end

    # Attributes that go in the "testcase" XML element.
    private def attributes
      {
        name:      result.example,
        status:    result,
        classname: classname,
      }
    end

    # Result to pull values from.
    private abstract def result

    # Adds additional content to the "testcase" XML block.
    # Override this to add more content.
    private def content(xml)
      # ...
    end

    # Java-ified class name created from the spec.
    private def classname
      "TODO"
    end
  end
end
