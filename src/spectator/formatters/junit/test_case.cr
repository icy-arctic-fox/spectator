require "./xml_element"

module Spectator::Formatters::JUnit
  abstract struct TestCase
    include XMLElement

    def initialize(*,
                   @name : String,
                   @class_name : String,
                   @assertions : Int32? = nil,
                   @time : Time::Span? = nil,
                   @file : String? = nil,
                   @line : Int32? = nil)
    end

    def to_xml(io : IO, indent : Int = 0) : Nil
      print_indent(io, indent)
      io << "<testcase"
      write_xml_attribute(io, "name", @name)
      write_xml_attribute(io, "classname", @class_name)
      write_xml_attribute(io, "assertions", @assertions)
      write_xml_attribute(io, "time", @time.try &.total_seconds)
      write_xml_attribute(io, "file", @file)
      write_xml_attribute(io, "line", @line)

      if has_inner_content?
        io.puts ">"
        print_inner(io, indent + 1)
        print_indent(io, indent)
        io << "</testcase>"
      else
        io << " />"
      end
    end

    private abstract def has_inner_content? : Bool

    private abstract def print_inner(io : IO, indent : Int) : Nil
  end
end
