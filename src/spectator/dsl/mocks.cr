require "../mocks"

module Spectator::DSL
  # Methods and macros for mocks and doubles.
  module Mocks
    # All defined double types.
    # Each tuple consists of the double name, defined context (example group),
    # and double type name relative to its context.
    DOUBLES = [] of {Symbol, Symbol, Symbol}

    macro double(name, **value_methods, &block)
      {% name_symbol = name.id.symbolize
         context_type_name = @type.name(generic_args: false).symbolize %}

      {% if @def %}
        {% # Find tuples with the same name.
 found_tuples = ::Spectator::DSL::Mocks::DOUBLES.select { |tuple| tuple[0] == name_symbol }

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
 found_tuple = found_tuples.last
 raise "Undefined double type '#{name}'" unless found_tuple

 # Store the type name used to define the underlying double.
 double_type_name = found_tuple[2].id %}

        {{double_type_name}}.new
      {% else %}
        {% # Construct a unique type name for the double by using the number of defined doubles.
 index = ::Spectator::DSL::Mocks::DOUBLES.size
 double_type_name = "Double#{index}".id.symbolize

 # Store information about how the double is defined and its context.
 # This is important for constructing an instance of the double later.
 ::Spectator::DSL::Mocks::DOUBLES << {name_symbol, context_type_name, double_type_name} %}

        ::Spectator::Double.define({{double_type_name}}, {{value_methods.double_splat}}) do
          {{block.body}}
        end
      {% end %}
    end
  end
end
