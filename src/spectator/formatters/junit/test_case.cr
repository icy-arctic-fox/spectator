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

      unless error = @error
        io << " />"
        return
      end

      write_context(io, indent) do
        if error.is_a?(Spectator::AssertionFailed)
          output_failure(io, error, indent + 2)
        else
          output_error(io, error, indent + 2)
        end
      end
    end

    private def write_context(io, indent, &) : Nil
      io.puts '>'
      yield
      indent.times { io << ' ' }
      io << "</testcase>"
    end

    private def output_failure(io, error, indent) : Nil
      indent.times { io << ' ' }
      io << "<failure"
      write_xml_attribute(io, "message", error.message)
      write_xml_attribute(io, "type", error.class.name)

      if error.fields.empty?
        io.puts " />"
        return
      end

      io.puts '>'
      error.fields.each do |(key, value)|
        HTML.escape(key, io)
        io << ": "
        HTML.escape(value, io)
        io.puts
      end
      indent.times { io << ' ' }
      io.puts "</failure>"
    end

    private def output_error(io, error, indent) : Nil
      indent.times { io << ' ' }
      io << "<error"
      write_xml_attribute(io, "message", error.message)
      write_xml_attribute(io, "type", error.class.name)

      unless backtrace = error.backtrace?
        io.puts " />"
        return
      end

      io << '>'
      io.puts
      HTML.escape(backtrace.join('\n'), io)
      io.puts
      indent.times { io << ' ' }
      io.puts "</error>"
    end
  end
end
