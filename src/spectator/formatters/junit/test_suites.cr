require "./test_suite"
require "./xml_element"

module Spectator::Formatters::JUnit
  struct TestSuites
    include XMLElement

    def initialize(*,
                   @name : String? = nil,
                   @tests : Int32? = nil,
                   @failures : Int32? = nil,
                   @errors : Int32? = nil,
                   @skipped : Int32? = nil,
                   @assertions : Int32? = nil,
                   @time : Time::Span? = nil,
                   @timestamp : Time? = nil,
                   @hostname : String? = nil,
                   @test_suites : Array(TestSuite) = [] of TestSuite)
    end

    def to_xml(io : IO, indent : Int = 0) : Nil
      print_indent(io, indent)
      io << "<testsuites"
      write_xml_attribute(io, "name", @name)
      write_xml_attribute(io, "tests", @tests)
      write_xml_attribute(io, "failures", @failures)
      write_xml_attribute(io, "errors", @errors)
      write_xml_attribute(io, "skipped", @skipped)
      write_xml_attribute(io, "assertions", @assertions)
      write_xml_attribute(io, "time", @time.try &.total_seconds)
      write_xml_attribute(io, "timestamp", @timestamp.try &.to_rfc3339)
      write_xml_attribute(io, "hostname", @hostname)
      if @test_suites.empty?
        io << " />"
      else
        io << ">"
        io.puts
        @test_suites.each do |test_suite|
          test_suite.to_xml(io, indent + 1)
          io.puts
        end
        print_indent(io, indent)
        io << "</testsuites>"
      end
    end
  end
end
