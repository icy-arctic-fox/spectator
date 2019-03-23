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
        @report.each do |result|
          test_case = result.call(JUnitTestCase) { |r| r }
          test_case.to_xml(xml)
        end
      end
    end

    private def name
      "TODO"
    end

    private def package
      "TODO"
    end
  end
end
