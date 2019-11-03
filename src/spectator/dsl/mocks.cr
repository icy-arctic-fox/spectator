require "../double"
require "../generic_method_stub"
require "../open_mock"
require "../stubs"

module Spectator::DSL
  macro double(name, &block)
    {% if block.is_a?(Nop) %}
      Double{{name.id}}.new(self)
    {% else %}
      class Double{{name.id}} < ::Spectator::Double
        def initialize(@spectator_test : {{@type.id}})
          super({{name.id.symbolize}})
        end

        forward_missing_to @spectator_test

        {{block.body}}
      end
    {% end %}
  end

  macro mock(name, &block)
    {% if block.is_a?(Nop) %}
      {{name}}.new.tap do |%inst|
        %inst.spectator_test = self
      end
    {% else %}
      {% resolved = name.resolve
        type = if resolved < Reference
          :class
        elsif resolved < Value
          :struct
        else
          :module
        end
      %}
      {{type.id}} ::{{resolved.id}}
        include ::Spectator::Stubs

        {{block.body}}
      end
    {% end %}
    {% debug %}
  end

  def allow(double : ::Spectator::Double)
    OpenMock.new(double)
  end

  macro receive(method_name, _source_file = __FILE__, _source_line = __LINE__)
    %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
    ::Spectator::GenericMethodStub(Nil).new({{method_name.symbolize}}, %source, ->{ nil })
  end
end
