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
    {% resolved = name.resolve
       type = if resolved < Reference
                :class
              elsif resolved < Value
                :struct
              else
                :module
              end %}
    {% begin %}
      {{type.id}} ::{{resolved.id}}
        include ::Spectator::Mocks::Stubs

        {{block.body}}
      end
    {% end %}
  end

  def allow(double : ::Spectator::Mocks::Double)
    Mocks::OpenMock.new(double)
  end

  macro receive(method_name, _source_file = __FILE__, _source_line = __LINE__)
    %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
    ::Spectator::Mocks::NilMethodStub.new({{method_name.symbolize}}, %source)
  end
end
