require "./method_call"
require "./mocked"
require "./stub"
require "./stubbed_name"
require "./value_stub"

module Spectator
  module Mock
    macro define_subclass(mocked_type, type_name, name = nil, **value_methods, &block)
      {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
      class {{type_name.id}} < {{mocked_type.id}}
        include ::Spectator::Mocked

        {% begin %}
          @_spectator_stubs = [
            {% for key, value in value_methods %}
              ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}}),
            {% end %}
          ] of ::Spectator::Stub
        {% end %}

        def _spectator_define_stub(stub : ::Spectator::Stub) : Nil
          @_spectator_stubs.unshift(stub)
        end

        private def _spectator_find_stub(call : ::Spectator::MethodCall) : ::Spectator::Stub?
          @_spectator_stubs.find &.===(call)
        end

        private def _spectator_stub_for_method?(method : Symbol) : Bool
          @_spectator_stubs.any? { |stub| stub.method == method }
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
          stub_hierarchy {{mocked_type.id}}

          {% if block %}{{block.body}}{% end %}
        end
      end
    end
  end
end
