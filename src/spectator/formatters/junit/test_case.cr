require "../../core/execution_result"
require "./xml_element"

module Spectator::Formatters::JUnit
  record(TestCase,
    name : String,
    class_name : String,
    assertions : Int32?,
    time : Time::Span?,
    file : String?,
    line : Int32?) do
    include XMLElement

    def self.from_result(result : Core::ExecutionResult) : self
      new(
        name: result.example.description,
        class_name: result.example.group.description,
        assertions: nil,
        time: result.elapsed,
        file: result.example.location.try &.file,
        line: result.example.location.try &.line
      )
    end

    def to_xml(io : IO) : Nil
      io << "<testcase"
      write_attribute("name", name, io)
      write_attribute("classname", class_name, io)
      assertions.try { |a| write_attribute("assertions", a, io) }
      time.try { |t| write_attribute("time", t.total_seconds, io) }
      file.try { |f| write_attribute("file", f, io) }
      line.try { |l| write_attribute("line", l, io) }
      io << " />"
    end
  end
end
