require "./test_suite"

module Spectator::Formatting::Components::JUnit
  # Root node of the JUnit XML document.
  # This is the "testsuites" element and all of its children.
  struct Root
    # Creates the root element.
    def initialize(@runtime : Time::Span, @suites : Array(TestSuite), *,
                   @total : Int32, @failures : Int32, @errors : Int32)
    end

    # Constructs the element from a report.
    def self.from_report(report)
      hostname = System.hostname
      counts = report.counts
      suites = report.examples.group_by { |example| example.location?.try(&.path) || "anonymous" }
      suites = suites.map do |file, examples|
        TestSuite.from_examples(file, examples, hostname)
      end

      new(report.runtime, suites,
        total: counts.total,
        failures: counts.fail,
        errors: counts.error)
    end

    # Produces the XML fragment.
    def to_xml(xml)
      xml.element("testsuites",
        tests: @total,
        failures: @failures,
        errors: @errors,
        time: @runtime.total_seconds,
        name: "Spec") do
        @suites.each(&.to_xml(xml))
      end
    end
  end
end
