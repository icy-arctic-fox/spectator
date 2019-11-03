require "../mocks"

module Spectator::DSL
  macro double(name, &block)
    {% if block.is_a?(Nop) %}
      Double{{name.id}}.new(self)
    {% else %}
      class Double{{name.id}} < ::Spectator::Mocks::Double
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
        include ::Spectator::Mocks::Stubs

        {{block.body}}
      end
    {% end %}
    {% debug %}
  end

  def allow(double : ::Spectator::Mocks::Double)
    Mocks::OpenMock.new(double)
  end

  macro receive(method_name, _source_file = __FILE__, _source_line = __LINE__)
    %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
    ::Spectator::Mocks::ValueMethodStub.new({{method_name.symbolize}}, %source, nil)
  end
end
