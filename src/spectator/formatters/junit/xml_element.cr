require "html"

module Spectator::Formatters::JUnit
  module XMLElement
    abstract def to_xml(io : IO) : Nil

    private def write_attribute(name : String, value, io : IO) : Nil
      io << ' ' << name << "=\""
      HTML.escape(value.to_s, io)
      io << "\""
    end
  end
end
