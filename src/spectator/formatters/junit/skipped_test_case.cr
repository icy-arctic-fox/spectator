require "./test_case"

module Spectator::Formatters::JUnit
  struct SkippedTestCase < TestCase
    def initialize(*,
                   name : String,
                   class_name : String,
                   assertions : Int32? = nil,
                   time : Time::Span? = nil,
                   file : String? = nil,
                   line : Int32? = nil,
                   @skip_message : String? = nil)
      super(name: name, class_name: class_name, assertions: assertions, time: time, file: file, line: line)
    end

    private def has_inner_content? : Bool
      true
    end

    private def print_inner(io : IO, indent : Int) : Nil
      print_indent(io, indent)
      io << "<skipped"
      write_xml_attribute(io, "message", @skip_message)
      io.puts " />"
    end
  end
end
