require "../mocks"

module Spectator::DSL
  # Methods and macros for mocks and doubles.
  module Mocks
    # All defined double types.
    # Each tuple consists of the double name, defined context (example group),
    # and double type name relative to its context.
    DOUBLES = [] of {Symbol, Symbol, Symbol}

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
 index = ::Spectator::DSL::Mocks::DOUBLES.size
 double_type_name = "Double#{index}".id
 null_double_type_name = "NullDouble#{index}".id

 # Store information about how the double is defined and its context.
 # This is important for constructing an instance of the double later.
 ::Spectator::DSL::Mocks::DOUBLES << {name.id.symbolize, @type.name(generic_args: false).symbolize, double_type_name.symbolize} %}

      # Define the plain double type.
      ::Spectator::Double.define({{double_type_name}}, {{name}}, {{**value_methods}}) do
        # Returns a new double that responds to undefined methods with itself.
        # See: `NullDouble`
        def as_null_object
          {{null_double_type_name}}.new(@stubs)
        end

        {% if block %}{{block.body}}{% end %}
      end

      {% begin %}
        # Define a matching null double type.
        ::Spectator::NullDouble.define({{null_double_type_name}}, {{name}}, {{**value_methods}}){% if block %} do
          {{block.body}}
        end{% end %}
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
 found_tuples = ::Spectator::DSL::Mocks::DOUBLES.select { |tuple| tuple[0] == name.id.symbolize }

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

      {% if found_tuple %}
        {{found_tuple[2].id}}.new
      {% else %}
        ::Spectator::LazyDouble.new({{name}}, {{**value_methods}})
      {% end %}
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
        {% if @def %}new_double{% else %}def_double{% end %}({{name}}, {{**value_methods}}){% if block %} do
          {{block.body}}
        end{% end %}
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
      new_double({{**value_methods}})
    end
  end
end
