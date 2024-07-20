require "./test_case"
require "./xml_element"

module Spectator::Formatters::JUnit
  struct TestSuite
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
                   @file : String? = nil,
                   @hostname : String? = nil,
                   @test_cases : Array(TestCase) = [] of TestCase)
    end

    def to_xml(io : IO) : Nil
      io << "<testsuite"
      write_xml_attribute(io, "name", @name)
      write_xml_attribute(io, "tests", @tests)
      write_xml_attribute(io, "failures", @failures)
      write_xml_attribute(io, "errors", @errors)
      write_xml_attribute(io, "skipped", @skipped)
      write_xml_attribute(io, "assertions", @assertions)
      write_xml_attribute(io, "time", @time.try &.total_seconds)
      write_xml_attribute(io, "timestamp", @timestamp.try &.to_rfc3339)
      write_xml_attribute(io, "file", @file)
      write_xml_attribute(io, "hostname", @hostname)
      if @test_cases.empty?
        io << " />"
      else
        io << ">"
        @test_cases.each do |test_case|
          test_case.to_xml(io)
        end
        io << "</testsuite>"
      end
    end
  end
end
