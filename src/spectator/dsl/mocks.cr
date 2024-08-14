require "../mocks"

module Spectator::DSL
  # Methods and macros for mocks and doubles.
  module Mocks
    # All defined double and mock types.
    # Each tuple consists of the double name or mocked type,
    # defined context (example group), and double type name relative to its context.
    TYPES = [] of {Symbol, Symbol, Symbol}

    # Defines a new double type.
    #
    # This must be called from outside of a method (where classes can be defined).
    # The *name* is the identifier used to reference the double, like when instantiating it.
    # Simple stubbed methods returning a value can be defined by *value_methods*.
    # More complex methods and stubs can be defined in a block passed to this macro.
    #
    # ```
    # def_double(:dbl, foo: 42, bar: "baz") do
    #   stub abstract def deferred : String
    # end
    # ```
    private macro def_double(name, **value_methods, &block)
      {% # Construct a unique type name for the double by using the number of defined doubles.
 index = ::Spectator::DSL::Mocks::TYPES.size
 double_type_name = "Double#{index}".id
 null_double_type_name = "NullDouble#{index}".id

 # Store information about how the double is defined and its context.
 # This is important for constructing an instance of the double later.
 ::Spectator::DSL::Mocks::TYPES << {name.id.symbolize, @type.name(generic_args: false).symbolize, double_type_name.symbolize} %}

      # Define the plain double type.
      ::Spectator::Double.define({{double_type_name}}, {{name}}, {{value_methods.double_splat}}) do
        # Returns a new double that responds to undefined methods with itself.
        # See: `NullDouble`
        def as_null_object
          {{null_double_type_name}}.new(@stubs)
        end

        {{block.body if block}}
      end

      {% begin %}
        # Define a matching null double type.
        ::Spectator::NullDouble.define({{null_double_type_name}}, {{name}}, {{value_methods.double_splat}}) {{block}}
      {% end %}
    end

    # Instantiates a double.
    #
    # The *name* is an optional identifier for the double.
    # If *name* was previously used to define a double (with `#def_double`),
    # then this macro returns a new instance of that previously defined double type.
    # Otherwise, a `LazyDouble` is created and returned.
    #
    # Initial stubbed values for methods can be provided with *value_methods*.
    #
    # ```
    # def_double(:dbl, foo: 42)
    #
    # specify do
    #   dbl = new_double(:dbl, foo: 7)
    #   expect(dbl.foo).to eq(7)
    #   lazy = new_double(:lazy, foo: 123)
    #   expect(lazy.foo).to eq(123)
    # end
    # ```
    private macro new_double(name = nil, **value_methods)
      {% # Find tuples with the same name.
 found_tuples = ::Spectator::DSL::Mocks::TYPES.select { |tuple| tuple[0] == name.id.symbolize }

 # Split the current context's type namespace into parts.
 type_parts = @type.name(generic_args: false).split("::")

 # Find tuples in the same context or a parent of where the double was defined.
 # This is done by comparing each part of their namespaces.
 found_tuples = found_tuples.select do |tuple|
   # Split the namespace of the context the double was defined in.
   context_parts = tuple[1].id.split("::")

   # Compare namespace parts between the context the double was defined in and this context.
   # This logic below is effectively comparing array elements, but with methods supported by macros.
   matches = context_parts.map_with_index { |part, i| part == type_parts[i] }
   matches.all? { |b| b }
 end

 # Sort the results by the number of namespace parts.
 # The last result will be the double type defined closest to the current context's type.
 found_tuples = found_tuples.sort_by do |tuple|
   tuple[1].id.split("::").size
 end
 found_tuple = found_tuples.last %}

      begin
        %double = {% if found_tuple %}
                    {{found_tuple[2].id}}.new({{value_methods.double_splat}})
                  {% else %}
                    ::Spectator::LazyDouble.new({{name}}, {{value_methods.double_splat}})
                  {% end %}
        ::Spectator::Harness.current?.try(&.cleanup { %double._spectator_reset })
        %double
      end
    end

    # Instantiates a class double.
    #
    # The *name* is an optional identifier for the double.
    # If *name* was previously used to define a double (with `#def_double`),
    # then this macro returns a previously defined double class.
    # Otherwise, `LazyDouble` is created and returned.
    #
    # Initial stubbed values for methods can be provided with *value_methods*.
    #
    # ```
    # def_double(:dbl) do
    #   stub def self.foo
    #     42
    #   end
    # end
    #
    # specify do
    #   dbl = class_double(:dbl)
    #   expect(dbl.foo).to eq(42)
    #   allow(dbl).to receive(:foo).and_return(123)
    #   expect(dbl.foo).to eq(123)
    # end
    # ```
    private macro class_double(name = nil, **value_methods)
      {% # Find tuples with the same name.
 found_tuples = ::Spectator::DSL::Mocks::TYPES.select { |tuple| tuple[0] == name.id.symbolize }

 # Split the current context's type namespace into parts.
 type_parts = @type.name(generic_args: false).split("::")

 # Find tuples in the same context or a parent of where the double was defined.
 # This is done by comparing each part of their namespaces.
 found_tuples = found_tuples.select do |tuple|
   # Split the namespace of the context the double was defined in.
   context_parts = tuple[1].id.split("::")

   # Compare namespace parts between the context the double was defined in and this context.
   # This logic below is effectively comparing array elements, but with methods supported by macros.
   matches = context_parts.map_with_index { |part, i| part == type_parts[i] }
   matches.all? { |b| b }
 end

 # Sort the results by the number of namespace parts.
 # The last result will be the double type defined closest to the current context's type.
 found_tuples = found_tuples.sort_by do |tuple|
   tuple[1].id.split("::").size
 end
 found_tuple = found_tuples.last %}

      begin
        %double = {% if found_tuple %}
                    {{found_tuple[2].id}}
                  {% else %}
                    ::Spectator::LazyDouble
                  {% end %}
        {% for key, value in value_methods %}
          %stub{key} = ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}})
          %double._spectator_define_stub(%stub{key})
        {% end %}
        ::Spectator::Harness.current?.try(&.cleanup { %double._spectator_reset })
        %double
      end
    end

    # Defines or instantiates a double.
    #
    # When used inside of a method, instantiates a new double.
    # See `#new_double`.
    #
    # When used outside of a method, defines a new double.
    # See `#def_double`.
    macro double(name, **value_methods, &block)
      {% begin %}
        {% if @def %}new_double{% else %}def_double{% end %}({{name}}, {{value_methods.double_splat}}) {{block}}
      {% end %}
    end

    # Instantiates a new double with predefined responses.
    #
    # This constructs a `LazyDouble`.
    #
    # ```
    # dbl = double(foo: 42)
    # expect(dbl.foo).to eq(42)
    # ```
    macro double(**value_methods)
      ::Spectator::LazyDouble.new({{value_methods.double_splat}})
    end

    # Defines a new mock type.
    #
    # This must be called from outside of a method (where classes can be defined).
    # *type* is the type being mocked.
    # The *name* is an optional identifier used in debug output.
    # Simple stubbed methods returning a value can be defined by *value_methods*.
    # More complex methods and stubs can be defined in a block passed to this macro.
    #
    # ```
    # abstract class MyClass
    #   def foo
    #     42
    #   end
    #
    #   def bar
    #     Time.utc
    #   end
    # end
    #
    # def_mock(MyClass, foo: 5) do
    #   stub def bar
    #     Time.utc(2022, 7, 10)
    #   end
    # end
    # ```
    private macro def_mock(type, name = nil, **value_methods, &block)
      {% resolved = type.resolve
         # Construct a unique type name for the mock by using the number of defined types.
         index = ::Spectator::DSL::Mocks::TYPES.size
         # The type is nested under the original so that any type names from the original can be resolved.
         mock_type_name = "Mock#{index}".id

         # Store information about how the mock is defined and its context.
         # This is important for constructing an instance of the mock later.
         ::Spectator::DSL::Mocks::TYPES << {type.id.symbolize, @type.name(generic_args: false).symbolize, "#{"::".id unless resolved.name.starts_with?("::")}#{resolved.name}::#{mock_type_name}".id.symbolize}

         base = if resolved.class?
                  :class
                elsif resolved.struct?
                  :struct
                else
                  :module
                end %}

      {% begin %}
        {{base.id}} {{"::".id unless resolved.name.starts_with?("::")}}{{resolved.name}}
          ::Spectator::Mock.define_subtype({{base}}, {{type.id}}, {{mock_type_name}}, {{name}}, {{value_methods.double_splat}}) {{block}}
        end
      {% end %}
    end

    # Instantiates a mock.
    #
    # *type* is the type being mocked.
    #
    # Initial stubbed values for methods can be provided with *value_methods*.
    #
    # ```
    # abstract class MyClass
    #   def foo
    #     42
    #   end
    #
    #   def bar
    #     Time.utc
    #   end
    # end
    #
    # def_mock(MyClass, foo: 5) do
    #   stub def bar
    #     Time.utc(2022, 7, 10)
    #   end
    # end
    #
    # specify do
    #   dbl = new_mock(MyClass, foo: 7)
    #   expect(dbl.foo).to eq(7)
    #   expect(dbl.bar).to eq(Time.utc(2022, 7, 10))
    # end
    # ```
    private macro new_mock(type, **value_methods)
      {% # Find tuples with the same name.
 found_tuples = ::Spectator::DSL::Mocks::TYPES.select { |tuple| tuple[0] == type.id.symbolize }

 # Split the current context's type namespace into parts.
 type_parts = @type.name(generic_args: false).split("::")

 # Find tuples in the same context or a parent of where the mock was defined.
 # This is done by comparing each part of their namespaces.
 found_tuples = found_tuples.select do |tuple|
   # Split the namespace of the context the double was defined in.
   context_parts = tuple[1].id.split("::")

   # Compare namespace parts between the context the double was defined in and this context.
   # This logic below is effectively comparing array elements, but with methods supported by macros.
   matches = context_parts.map_with_index { |part, i| part == type_parts[i] }
   matches.all? { |b| b }
 end

 # Sort the results by the number of namespace parts.
 # The last result will be the double type defined closest to the current context's type.
 found_tuples = found_tuples.sort_by do |tuple|
   tuple[1].id.split("::").size
 end
 found_tuple = found_tuples.last %}

      {% if found_tuple %}
        {{found_tuple[2].id}}.new.tap do |%mock|
          {% for key, value in value_methods %}
            %stub{key} = ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}})
            %mock._spectator_define_stub(%stub{key})
          {% end %}
          ::Spectator::Harness.current?.try(&.cleanup { %mock._spectator_reset })
        end
      {% else %}
        {% raise "Type `#{type.id}` must be previously mocked before attempting to instantiate." %}
      {% end %}
    end

    # Defines or instantiates a mock.
    #
    # When used inside of a method, instantiates a new mock.
    # See `#new_mock`.
    #
    # When used outside of a method, defines a new mock.
    # See `#def_mock`.
    macro mock(type, **value_methods, &block)
      {% raise "First argument of `mock` must be a type name, not #{type}" unless type.is_a?(Path) || type.is_a?(Generic) || type.is_a?(Union) || type.is_a?(Metaclass) || type.is_a?(TypeNode) %}
      {% begin %}
        {% if @def %}new_mock{% else %}def_mock{% end %}({{type}}, {{value_methods.double_splat}}) {{block}}
      {% end %}
    end

    # Instantiates a class mock.
    #
    # *type* is the type being mocked.
    #
    # Initial stubbed values for methods can be provided with *value_methods*.
    #
    # ```
    # class MyClass
    #   def self.foo
    #     42
    #   end
    # end
    #
    # def_mock(MyClass)
    #
    # specify do
    #   mock = class_mock(MyClass, foo: 5)
    #   expect(dbl.foo).to eq(5)
    #   allow(dbl).to receive(:foo).and_return(123)
    #   expect(dbl.foo).to eq(123)
    # end
    # ```
    private macro class_mock(type, **value_methods)
      {% # Find tuples with the same name.
 found_tuples = ::Spectator::DSL::Mocks::TYPES.select { |tuple| tuple[0] == type.id.symbolize }

 # Split the current context's type namespace into parts.
 type_parts = @type.name(generic_args: false).split("::")

 # Find tuples in the same context or a parent of where the mock was defined.
 # This is done by comparing each part of their namespaces.
 found_tuples = found_tuples.select do |tuple|
   # Split the namespace of the context the double was defined in.
   context_parts = tuple[1].id.split("::")

   # Compare namespace parts between the context the double was defined in and this context.
   # This logic below is effectively comparing array elements, but with methods supported by macros.
   matches = context_parts.map_with_index { |part, i| part == type_parts[i] }
   matches.all? { |b| b }
 end

 # Sort the results by the number of namespace parts.
 # The last result will be the double type defined closest to the current context's type.
 found_tuples = found_tuples.sort_by do |tuple|
   tuple[1].id.split("::").size
 end
 found_tuple = found_tuples.last %}

      {% if found_tuple %}
        begin
          %mock = {{found_tuple[2].id}}
          {% for key, value in value_methods %}
            %stub{key} = ::Spectator::ValueStub.new({{key.id.symbolize}}, {{value}})
            %mock._spectator_define_stub(%stub{key})
          {% end %}
          ::Spectator::Harness.current?.try(&.cleanup { %mock._spectator_reset })
          %mock
        end
      {% else %}
        {% raise "Type `#{type.id}` must be previously mocked before attempting to instantiate." %}
      {% end %}
    end

    # Injects mock (stub) functionality into an existing type.
    #
    # Warning: Using this will modify the type being tested.
    #   This may result in different behavior between test and non-test code.
    #
    # This must be used instead of `def_mock` if a concrete struct is tested.
    # The `mock` method is not necessary to create a type with an injected mock.
    # The type can be used as it would normally instead.
    # However, stub information may leak between examples.
    #
    # The *type* is the name of the type to inject mock functionality into.
    # Initial stubbed values for methods can be provided with *value_methods*.
    #
    # ```
    # struct MyStruct
    #   def foo
    #     42
    #   end
    # end
    #
    # inject_mock(MyStruct, foo: 5)
    #
    # specify do
    #   inst = MyStruct.new
    #   expect(inst.foo).to eq(5)
    #   allow(inst).to receive(:foo).and_return(123)
    #   expect(inst.foo).to eq(123)
    # end
    # ```
    macro inject_mock(type, **value_methods, &block)
      {% resolved = type.resolve
         base = if resolved.class?
                  :class
                elsif resolved.struct?
                  :struct
                else
                  :module
                end

         # Store information about how the mock is defined and its context.
         # This isn't required, but new_mock() should still find this type.
         ::Spectator::DSL::Mocks::TYPES << {type.id.symbolize, @type.name(generic_args: false).symbolize, resolved.name.symbolize} %}

      ::Spectator::Mock.inject({{base}}, {{resolved.name}}, {{value_methods.double_splat}}) {{block}}
    end

    # Targets a stubbable object (such as a mock or double) for operations.
    #
    # The *stubbable* must be a `Stubbable` or `StubbedType`.
    # This method is expected to be followed up with `.to receive()`.
    #
    # ```
    # dbl = dbl(:foobar)
    # allow(dbl).to receive(:foo).and_return(42)
    # ```
    def allow(stubbable : Stubbable | StubbedType)
      ::Spectator::Allow.new(stubbable)
    end

    # Helper method producing a compilation error when attempting to stub a non-stubbable object.
    #
    # Triggered in cases like this:
    # ```
    # allow(42).to receive(:to_s).and_return("123")
    # ```
    def allow(stubbable)
      {% raise "Target of `allow()` must be stubbable (mock or double)." %}
    end

    # Begins the creation of a stub.
    #
    # The *method* is the name of the method being stubbed.
    # It should not define any parameters, it should be just the method name as a literal symbol or string.
    #
    # Alone, this method returns a `NullStub`, which allows a stubbable object to return nil from a method.
    # This macro is typically followed up with a method like `and_return` to change the stub's behavior.
    #
    # ```
    # dbl = dbl(:foobar)
    # allow(dbl).to receive(:foo)
    # expect(dbl.foo).to be_nil
    #
    # allow(dbl).to receive(:foo).and_return(42)
    # expect(dbl.foo).to eq(42)
    # ```
    #
    # A block can be provided to be run every time the stub is invoked.
    # The value returned by the block is returned by the stubbed method.
    #
    # ```
    # dbl = dbl(:foobar)
    # allow(dbl).to receive(:foo) { 42 }
    # expect(dbl.foo).to eq(42)
    # ```
    macro receive(method, *, _file = __FILE__, _line = __LINE__, &block)
      {% if block %}
        %proc = ->(%args : ::Spectator::AbstractArguments) {
          {% if !block.args.empty? %}{{*block.args}} = %args {% end %}
          {{block.body}}
        }
        ::Spectator::ProcStub.new({{method.id.symbolize}}, %proc, location: ::Spectator::Location.new({{_file}}, {{_line}}))
      {% else %}
        ::Spectator::NullStub.new({{method.id.symbolize}}, location: ::Spectator::Location.new({{_file}}, {{_line}}))
      {% end %}
    end

    # Returns empty arguments.
    def no_args
      ::Spectator::Arguments.none
    end

    # Indicates any arguments can be used (no constraint).
    def any_args
      ::Spectator::Arguments.any
    end
  end
end
