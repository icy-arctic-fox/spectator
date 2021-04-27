module Spectator::Formatting
  # Mapping of a single spec file into a JUnit test suite.
  private struct JUnitTestSuite
    # Creates the JUnit test suite.
    # The *path* should be the file that all results are from.
    # The *examples* is a subset of all examples that share the path.
    def initialize(@path : String, examples : Array(Example))
      @report = Report.new(examples)
    end

    # Generates the XML for the test suite (and all nested test cases).
    def to_xml(xml : ::XML::Builder)
      xml.element("testsuite",
        tests: @report.example_count,
        failures: @report.failed_count,
        errors: @report.error_count,
        skipped: @report.pending_count,
        time: @report.runtime.total_seconds,
        name: name,
        package: package) do
        add_test_cases(xml)
      end
    end

    # Adds the test case elements to the XML.
    private def add_test_cases(xml)
      @report.each do |example|
        test_case = example.result.accept(JUnitTestCaseSelector) { example }
        test_case.to_xml(xml)
      end
    end

    # Java-ified name of the test suite.
    private def name
      file = File.basename(@path)
      ext = File.extname(file)
      name = file[0...-(ext.size)]
      name.camelcase
    end

    # Java-ified package (path) of the test suite.
    private def package
      file = File.basename(@path)
      dir = @path[0...-(file.size + 1)]
      dir.gsub('/', '.').underscore
    end

    # Selector for creating a JUnit test case based on a result.
    private module JUnitTestCaseSelector
      extend self

      # Creates a successful JUnit test case.
      def pass(example)
        SuccessfulJUnitTestCase.new(example)
      end

      # Creates a failure JUnit test case.
      def failure(example)
        FailureJUnitTestCase.new(example)
      end

      # Creates an error JUnit test case.
      def error(example)
        ErrorJUnitTestCase.new(example)
      end

      # Creates a skipped JUnit test case.
      def pending(example)
        SkippedJUnitTestCase.new(example)
      end
    end
  end
end
