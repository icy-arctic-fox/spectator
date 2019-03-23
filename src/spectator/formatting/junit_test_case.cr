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
        status:    status,
        classname: classname,
      }
    end

    # Result to pull values from.
    private abstract def result

    # Status string specific to the result type.
    private abstract def status : String

    # Adds additional content to the "testcase" XML block.
    # Override this to add more content.
    private def content(xml)
      # ...
    end

    # Java-ified class name created from the spec.
    private def classname
      path = result.example.source.path
      file = File.basename(path)
      ext = File.extname(file)
      name = file[0...-(ext.size)]
      dir = path[0...-(file.size + 1)]
      {dir.gsub('/', '.').underscore, name.camelcase}.join('.')
    end
  end
end
