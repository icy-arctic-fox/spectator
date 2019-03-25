require "xml"

module Spectator::Formatting
  # Formatter for producing a JUnit XML report.
  class JUnitFormatter < Formatter
    # Name of the JUnit output file.
    private JUNIT_XML_FILE = "output.xml"

    # Name of the top-level test suites block.
    private NAME = "Spec"

    # Creates the formatter.
    # By default, output is sent to STDOUT.
    def initialize(output_dir : String)
      path = File.join(output_dir, JUNIT_XML_FILE)
      @io = File.open(path, "w")
      @xml = XML::Builder.new(@io)
    end

    # Called when a test suite is starting to execute.
    def start_suite(suite : TestSuite)
      @xml.start_document(encoding: "UTF-8")
    end

    # Called when a test suite finishes.
    # The results from the entire suite are provided.
    # The *profile* value does nothing for this formatter.
    def end_suite(report : Report, profile : Profile?)
      test_suites_block(report)
      @xml.end_document
      @xml.flush
      @io.close
    end

    # Called before a test starts.
    def start_example(example : Example)
    end

    # Called when a test finishes.
    # The result of the test is provided.
    def end_example(result : Result)
    end

    # Creates the "testsuites" block in the XML.
    private def test_suites_block(report)
      @xml.element("testsuites",
        tests: report.example_count,
        failures: report.failed_count,
        errors: report.error_count,
        time: report.runtime.total_seconds,
        name: NAME) do
        add_test_suites(report)
      end
    end

    # Adds all of the individual test suite blocks.
    private def add_test_suites(report)
      report.group_by(&.example.source.path).each do |path, results|
        JUnitTestSuite.new(path, results).to_xml(@xml)
      end
    end
  end
end
