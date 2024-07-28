require "../../assertion_failed"
require "./test_case"

module Spectator::Formatters::JUnit
  struct FailedTestCase < TestCase
    def initialize(*,
                   name : String,
                   class_name : String,
                   assertions : Int32? = nil,
                   time : Time::Span? = nil,
                   file : String? = nil,
                   line : Int32? = nil,
                   @error : Exception)
      super(name: name, class_name: class_name, assertions: assertions, time: time, file: file, line: line)
    end

    private def has_inner_content? : Bool
      true
    end

    private def print_inner(io : IO, indent : Int) : Nil
      error = @error
      type = error.is_a?(AssertionFailed) ? "failure" : "error"
      print_indent(io, indent)
      io << '<' << type
      write_xml_attribute(io, "message", error.message)
      write_xml_attribute(io, "type", error.class.name)

      if backtrace = error.backtrace?
        io.puts '>'
        HTML.escape(backtrace.join('\n'), io)
        io.puts
        print_indent(io, indent)
        io << "</" << type
        io.puts '>'
      else
        io.puts " />"
      end
    end
  end
end
