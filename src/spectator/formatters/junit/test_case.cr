require "./xml_element"

module Spectator::Formatters::JUnit
  struct TestCase
    include XMLElement

    def initialize(*,
                   @name : String,
                   @class_name : String,
                   @assertions : Int32? = nil,
                   @time : Time::Span? = nil,
                   @file : String? = nil,
                   @line : Int32? = nil,
                   @error : Exception? = nil)
    end

    def to_xml(io : IO, indent : Int = 0) : Nil
      indent.times { io << ' ' }
      io << "<testcase"
      write_xml_attribute(io, "name", @name)
      write_xml_attribute(io, "classname", @class_name)
      write_xml_attribute(io, "assertions", @assertions)
      write_xml_attribute(io, "time", @time.try &.total_seconds)
      write_xml_attribute(io, "file", @file)
      write_xml_attribute(io, "line", @line)

      if error = @error
        io.puts '>'
        output_failure(io, error, indent + 2)
        io << "</testcase>"
      else
        io << " />"
      end
    end

    private def output_failure(io, error, indent) : Nil
      type = error.is_a?(AssertionFailed) ? "failure" : "error"
      indent.times { io << ' ' }
      io << '<' << type
      write_xml_attribute(io, "message", error.message)
      write_xml_attribute(io, "type", error.class.name)

      if backtrace = error.backtrace?
        io.puts '>'
        HTML.escape(backtrace.join('\n'), io)
        io.puts
        indent.times { io << ' ' }
        io << "</" << type
        io.puts '>'
      else
        io.puts " />"
      end
    end
  end
end
