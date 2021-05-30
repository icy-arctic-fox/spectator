require "xml"
require "./formatter"

module Spectator::Formatting
  # Produces a JUnit compatible XML file containing the test results.
  class JUnitFormatter < Formatter
    # Default XML file name.
    private OUTPUT_FILE = "output.xml"

    # XML builder for the entire document.
    private getter! xml : XML::Builder

    # Output stream for the XML file.
    private getter! io : IO

    # Creates the formatter.
    # The *output_path* can be a directory or path of an XML file.
    # If the former, then an "output.xml" file will be generated in the specified directory.
    def initialize(output_path = OUTPUT_FILE)
      @output_path = if output_path.ends_with?(".xml")
                       output_path
                     else
                       File.join(output_path, OUTPUT_FILE)
                     end
    end

    # Prepares the formatter for writing.
    def start(_notification)
      @io = io = File.open(@output_path, "w")
      @xml = xml = XML::Builder.new(io)
      xml.start_document("1.0", "UTF-8")
    end

    # Invoked after testing completes with summarized information from the test suite.
    # Unfortunately, the JUnit specification is not conducive to streaming data.
    # All results are gathered at the end, then the report is generated.
    def dump_summary(notification)
      report = notification.report
      root = Components::JUnit::Root.from_report(report)
      root.to_xml(xml)
    end

    # Invoked at the end of the program.
    # Allows the formatter to perform any cleanup and teardown.
    def close
      xml.end_document
      xml.flush
      io.close
    end
  end
end
