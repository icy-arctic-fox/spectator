require "../double"
require "../generic_method_stub"
require "../open_mock"

module Spectator::DSL
  macro double(name, &block)
    {% if block.is_a?(Nop) %}
      Double{{name.id}}.new(self)
    {% else %}
      class Double{{name.id}} < ::Spectator::Double
        private class Internal
          def initialize(@test : {{@type.id}})
          end

          forward_missing_to @test
        end

        def initialize(test : {{@type.id}})
          @internal = Internal.new(test)
        end

        {{block.body}}
      end
    {% end %}
  end

  def allow(double : ::Spectator::Double)
    OpenMock.new(double)
  end

  macro receive(method_name, _source_file = __FILE__, _source_line = __LINE__)
    %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
    ::Spectator::GenericMethodStub(Nil).new({{method_name.symbolize}}, %source)
  end
end
