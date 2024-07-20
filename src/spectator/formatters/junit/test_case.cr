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
      case error = @error
      when Nil # Passed
        io << " />"
      when Spectator::AssertionFailed # Failed
        output_failure(io, "failure", error, indent + 2)
      else # Error
        output_failure(io, "error", error, indent + 2)
      end
    end

    private def output_failure(io, type, error, indent) : Nil
      io << ">"
      io.puts
      indent.times { io << ' ' }
      io << '<' << type
      write_xml_attribute(io, "message", error.message)
      write_xml_attribute(io, "type", error.class.name)
      if backtrace = error.backtrace?
        io << '>'
        io.puts
        HTML.escape(backtrace.join('\n'), io)
        io.puts
        io << "</" << type << '>'
      else
        io << " />"
      end
      io.puts
      io << "</testcase>"
    end
  end
end
