require "./method_call"
require "./mocked"
require "./reference_mock_registry"
require "./stub"
require "./stubbed_name"
require "./value_mock_registry"
require "./value_stub"

module Spectator
  module Mock
    macro define_subtype(base, mocked_type, type_name, name = nil, **value_methods, &block)
      {% begin %}
        {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
        {{base.id}} {{type_name.id}} < {{mocked_type.id}}
          include ::Spectator::Mocked

          {% begin %}
            private getter(_spectator_stubs) do
              [
                {% for key, value in value_methods %}
                  ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}}),
                {% end %}
              ] of ::Spectator::Stub
            end
          {% end %}

          def _spectator_clear_stubs : Nil
            @_spectator_stubs = nil
          end

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
      {% end %}
    end

    macro inject(base, type_name, name = nil, **value_methods, &block)
      {% begin %}
        {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
        {{base.id}} {{type_name.id}}
          include ::Spectator::Mocked

          {% if base == :class %}
            @@_spectator_mock_registry = ::Spectator::ReferenceMockRegistry.new
          {% elsif base == :struct %}
            @@_spectator_mock_registry = ::Spectator::ValueMockRegistry(self).new
          {% else %}
            {% raise "Unsupported base type #{base} for injecting mock" %}
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

          def _spectator_clear_stubs : Nil
            @@_spectator_mock_registry.delete(self)
          end

          # Returns the mock's name formatted for user output.
          private def _spectator_stubbed_name : String
            \{% if anno = @type.annotation(::Spectator::StubbedName) %}
              "#<Mock {{type_name.id}} \"" + \{{(anno[0] || :Anonymous.id).stringify}} + "\">"
            \{% else %}
              "#<Mock {{type_name.id}}>"
            \{% end %}
          end

          macro finished
            stub_type {{type_name.id}}

            {% if block %}{{block.body}}{% end %}
          end
        end
      {% end %}
    end
  end
end
