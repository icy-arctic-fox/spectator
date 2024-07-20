require "html"

module Spectator::Formatters::JUnit
  module XMLElement
    abstract def to_xml(io : IO) : Nil

    private def write_xml_attribute(io : IO, name : String, value) : Nil
      return if value.nil?

      io << ' ' << name << "=\""
      HTML.escape(value.to_s, io)
      io << '"'
    end
  end
end
