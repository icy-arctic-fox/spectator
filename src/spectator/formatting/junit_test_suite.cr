module Spectator::Formatting
  # Mapping of a single spec file into a JUnit test suite.
  private struct JUnitTestSuite
    # Creates the JUnit test suite.
    # The *path* should be the file that all results are from.
    # The *results* is a subset of all results that share the path.
    def initialize(@path : String, results : Array(Result))
      @report = Report.new(results)
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
      @report.each do |result|
        test_case = result.call(JUnitTestCaseSelector) { |r| r }
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
      def success(result)
        SuccessfulJUnitTestCase.new(result.as(SuccessfulResult))
      end

      # Creates a failure JUnit test case.
      def failure(result)
        FailureJUnitTestCase.new(result.as(FailedResult))
      end

      # Creates an error JUnit test case.
      def error(result)
        ErrorJUnitTestCase.new(result.as(ErroredResult))
      end

      # Creates a skipped JUnit test case.
      def pending(result)
        SkippedJUnitTestCase.new(result.as(PendingResult))
      end
    end
  end
end
