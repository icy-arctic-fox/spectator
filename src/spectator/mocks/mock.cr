require "./method_call"
require "./mocked"
require "./reference_mock_registry"
require "./stub"
require "./stubbed_name"
require "./value_mock_registry"
require "./value_stub"

module Spectator
  module Mock
    macro define_subclass(mocked_type, type_name, name = nil, **value_methods, &block)
      {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
      class {{type_name.id}} < {{mocked_type.id}}
        include ::Spectator::Mocked

        {% begin %}
          private getter _spectator_stubs = [
            {% for key, value in value_methods %}
              ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}}),
            {% end %}
          ] of ::Spectator::Stub
        {% end %}

        # Returns the mock's name formatted for user output.
        private def _spectator_stubbed_name : String
          \{% if anno = @type.annotation(::Spectator::StubbedName) %}
            "#<Mock {{mocked_type.id}} \"" + \{{(anno[0] || :Anonymous.id).stringify}} + "\">"
          \{% else %}
            "#<Mock {{mocked_type.id}}>"
          \{% end %}
        end

        macro finished
          stub_type {{mocked_type.id}}

          {% if block %}{{block.body}}{% end %}
        end
      end
    end

    macro inject(type_name, name = nil, **value_methods, &block)
      {% type = type_name.resolve
         base = if type.class?
                  :class
                elsif type.struct?
                  :struct
                else
                  raise "Unsupported mockable type - #{type}"
                end.id %}

      {% begin %}
        {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
        {{base}} ::{{type.name}}
          include ::Spectator::Mocked

          {% if type.class? %}
            @@_spectator_mock_registry = ::Spectator::ReferenceMockRegistry.new
          {% elsif type.struct? %}
            @@_spectator_mock_registry = ::Spectator::ValueMockRegistry(self).new
          {% else %}
            {% raise "Unsupported type for injecting mock" %}
          {% end %}

          private def _spectator_stubs
            @@_spectator_mock_registry.fetch(self) do
              {% begin %}
                [
                  {% for key, value in value_methods %}
                    ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}}),
                  {% end %}
                ] of ::Spectator::Stub
              {% end %}
            end
          end

          # Returns the mock's name formatted for user output.
          private def _spectator_stubbed_name : String
            \{% if anno = @type.annotation(::Spectator::StubbedName) %}
              "#<Mock {{type.name}} \"" + \{{(anno[0] || :Anonymous.id).stringify}} + "\">"
            \{% else %}
              "#<Mock {{type.name}}>"
            \{% end %}
          end

          macro finished
            stub_type {{type.name}}

            {% if block %}{{block.body}}{% end %}
          end
        end
      {% end %}
    end
  end
end
