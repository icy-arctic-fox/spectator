require "./method_call"
require "./mocked"
require "./mock_registry"
require "./reference_mock_registry"
require "./stub"
require "./stubbed_name"
require "./stubbed_type"
require "./value_mock_registry"
require "./value_stub"

module Spectator
  # Module providing macros for defining new mocks from existing types and injecting mock features into concrete types.
  module Mock
    # Defines a type that inherits from another, existing type.
    # The newly defined subtype will have mocking functionality.
    #
    # Methods from the inherited type will be overridden to support stubs.
    # *base* is the keyword for the type being defined - class or struct.
    # *mocked_type* is the original type to inherit from.
    # *type_name* is the name of the new type to define.
    # An optional *name* of the mock can be provided.
    # Any key-value pairs provided with *value_methods* are used as initial stubs for the mocked type.
    #
    # A block can be provided to define additional methods and stubs.
    # The block is evaluated in the context of the derived type.
    #
    # ```
    # Mock.define_subtype(:class, SomeType, meth1: 42, meth2: "foobar") do
    #   stub abstract def meth3 : Symbol
    #
    #   # Default implementation with a dynamic value.
    #   stub def meth4
    #     Time.utc
    #   end
    # end
    # ```
    macro define_subtype(base, mocked_type, type_name, name = nil, **value_methods, &block)
      {% begin %}
        {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
        {% if base.id == :module.id %}
          {{base.id}} {{type_name.id}}
            include {{mocked_type.id}}

            # Mock class that includes the mocked module {{mocked_type.id}}
            {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
            private class ClassIncludingMock{{type_name.id}}
              include {{type_name.id}}
            end

            # Returns a mock class that includes the mocked module {{mocked_type.id}}.
            def self.new(*args, **kwargs) : ClassIncludingMock{{type_name.id}}
              # FIXME: Creating the instance normally with `.new` causing infinite recursion.
              inst = ClassIncludingMock{{type_name.id}}.allocate
              inst.initialize(*args, **kwargs)
              inst
            end

            # Returns a mock class that includes the mocked module {{mocked_type.id}}.
            def self.new(*args, **kwargs) : ClassIncludingMock{{type_name.id}}
              # FIXME: Creating the instance normally with `.new` causing infinite recursion.
              inst = ClassIncludingMock{{type_name.id}}.allocate
              inst.initialize(*args, **kwargs) { |*yargs| yield *yargs }
              inst
            end

        {% else %}
          {{base.id}} {{type_name.id}} < {{mocked_type.id}}
        {% end %}
          include ::Spectator::Mocked
          extend ::Spectator::StubbedType

          {% begin %}
            private getter(_spectator_stubs) do
              [
                {% for key, value in value_methods %}
                  ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}}),
                {% end %}
              ] of ::Spectator::Stub
            end
          {% end %}

          def _spectator_remove_stub(stub : ::Spectator::Stub) : ::Nil
            @_spectator_stubs.try &.delete(stub)
          end

          def _spectator_clear_stubs : ::Nil
            @_spectator_stubs = nil
          end

          private class_getter _spectator_stubs : ::Array(::Spectator::Stub) = [] of ::Spectator::Stub

          class_getter _spectator_calls : ::Array(::Spectator::MethodCall) = [] of ::Spectator::MethodCall

          getter _spectator_calls = [] of ::Spectator::MethodCall

          # Returns the mock's name formatted for user output.
          private def _spectator_stubbed_name : ::String
            \{% if anno = @type.annotation(::Spectator::StubbedName) %}
              "#<Mock {{mocked_type.id}} \"" + \{{(anno[0] || :Anonymous.id).stringify}} + "\">"
            \{% else %}
              "#<Mock {{mocked_type.id}}>"
            \{% end %}
          end

          private def self._spectator_stubbed_name : ::String
            \{% if anno = @type.annotation(::Spectator::StubbedName) %}
              "#<Class Mock {{mocked_type.id}} \"" + \{{(anno[0] || :Anonymous.id).stringify}} + "\">"
            \{% else %}
              "#<Class Mock {{mocked_type.id}}>"
            \{% end %}
          end

          macro finished
            stub_type {{mocked_type.id}}

            {{block.body if block}}
          end
        end
      {% end %}
    end

    # Injects mock functionality into an existing type.
    #
    # Generally this method of mocking should be avoiding.
    # It modifies types being tested, the mock functionality won't exist outside of tests.
    # This option should only be used when sub-types are not possible (e.g. concrete struct).
    #
    # Methods in the type will be overridden to support stubs.
    # The original method functionality will still be accessible, but pass through mock code first.
    # *base* is the keyword for the type being defined - class or struct.
    # *type_name* is the name of the type to inject mock functionality into.
    # This _must_ be full, resolvable path to the type.
    # An optional *name* of the mock can be provided.
    # Any key-value pairs provided with *value_methods* are used as initial stubs for the mocked type.
    #
    # A block can be provided to define additional methods and stubs.
    # The block is evaluated in the context of the derived type.
    #
    # ```
    # Mock.inject(:struct, SomeType, meth1: 42, meth2: "foobar") do
    #   stub abstract def meth3 : Symbol
    #
    #   # Default implementation with a dynamic value.
    #   stub def meth4
    #     Time.utc
    #   end
    # end
    # ```
    macro inject(base, type_name, name = nil, **value_methods, &block)
      {% begin %}
        {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
        {{base.id}} {{"::".id unless type_name.id.starts_with?("::")}}{{type_name.id}}
          include ::Spectator::Mocked
          extend ::Spectator::StubbedType

          {% if base == :class %}
            @@_spectator_mock_registry = ::Spectator::ReferenceMockRegistry.new
          {% elsif base == :struct %}
            @@_spectator_mock_registry = ::Spectator::ValueMockRegistry(self).new
          {% else %}
            @@_spectator_mock_registry = ::Spectator::MockRegistry.new
          {% end %}

          private class_getter _spectator_stubs : ::Array(::Spectator::Stub) = [] of ::Spectator::Stub

          class_getter _spectator_calls : ::Array(::Spectator::MethodCall) = [] of ::Spectator::MethodCall

          private def _spectator_stubs
            entry = @@_spectator_mock_registry.fetch(self) do
              _spectator_default_stubs
            end
            entry.stubs
          end

          def _spectator_remove_stub(stub : ::Spectator::Stub) : ::Nil
            @@_spectator_mock_registry[self]?.try &.stubs.delete(stub)
          end

          def _spectator_clear_stubs : ::Nil
            @@_spectator_mock_registry.delete(self)
          end

          def _spectator_calls
            entry = @@_spectator_mock_registry.fetch(self) do
              _spectator_default_stubs
            end
            entry.calls
          end

          private def _spectator_default_stubs
            {% begin %}
              [
                {% for key, value in value_methods %}
                  ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}}),
                {% end %}
              ] of ::Spectator::Stub
            {% end %}
          end

          # Returns the mock's name formatted for user output.
          private def _spectator_stubbed_name : ::String
            \{% if anno = @type.annotation(::Spectator::StubbedName) %}
              "#<Mock {{type_name.id}} \"" + \{{(anno[0] || :Anonymous.id).stringify}} + "\">"
            \{% else %}
              "#<Mock {{type_name.id}}>"
            \{% end %}
          end

          # Returns the mock's name formatted for user output.
          private def self._spectator_stubbed_name : ::String
            \{% if anno = @type.annotation(::Spectator::StubbedName) %}
              "#<Class Mock {{type_name.id}} \"" + \{{(anno[0] || :Anonymous.id).stringify}} + "\">"
            \{% else %}
              "#<Class Mock {{type_name.id}}>"
            \{% end %}
          end

          macro finished
            stub_type {{type_name.id}}

            {{block.body if block}}
          end
        end
      {% end %}
    end
  end
end
