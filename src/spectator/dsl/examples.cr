require "../source"
require "./builder"

module Spectator::DSL
  # DSL methods for defining examples and test code.
  module Examples
    # Defines a macro to generate code for an example.
    # The *name* is the name given to the macro.
    # TODO: Mark example as pending if block is omitted.
    macro define_example(name)
      macro {{name.id}}(what = nil, &block)
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}
        \{% raise "A description or block must be provided. Cannot use '{{name.id}}' alone." unless what || block %}

        def \%test # TODO: Pass example instance.
          \{{block.body}}
        end

        ::Spectator::DSL::Builder.add_example(
          _spectator_example_name(\{{what}}),
          ::Spectator::Source.new(\{{block.filename}}, \{{block.line_number}}),
          \{{@type.name}}.new
        ) { |example, context| context.as(\{{@type.name}}).\%test }
      end
    end

    # Inserts the correct representation of a example's name.
    # If *what* is a string, then it is dropped in as-is.
    # For anything else, it is stringified.
    # This is intended to be used to convert a description from the spec DSL to `ExampleNode#name`.
    private macro _spectator_example_name(what)
      {% if what.is_a?(StringLiteral) ||
              what.is_a?(StringInterpolation) ||
              what.is_a?(NilLiteral) %}
        {{what}}
      {% else %}
        {{what.stringify}}
      {% end %}
    end

    # Defines an example.
    #
    # If a block is given, it is treated as the code to test.
    # The block is provided the current example instance as an argument.
    #
    # The first argument names the example (test).
    # Typically, this specifies what is being tested.
    # It has no effect on the test and is purely used for output.
    # If omitted, a name is generated from the first assertion in the test.
    #
    # The example will be marked as pending if the block is omitted.
    # A block or name must be provided.
    define_example :example

    # Defines an example.
    #
    # If a block is given, it is treated as the code to test.
    # The block is provided the current example instance as an argument.
    #
    # The first argument names the example (test).
    # Typically, this specifies what is being tested.
    # It has no effect on the test and is purely used for output.
    # If omitted, a name is generated from the first assertion in the test.
    #
    # The example will be marked as pending if the block is omitted.
    # A block or name must be provided.
    define_example :it

    # Defines an example.
    #
    # If a block is given, it is treated as the code to test.
    # The block is provided the current example instance as an argument.
    #
    # The first argument names the example (test).
    # Typically, this specifies what is being tested.
    # It has no effect on the test and is purely used for output.
    # If omitted, a name is generated from the first assertion in the test.
    #
    # The example will be marked as pending if the block is omitted.
    # A block or name must be provided.
    define_example :specify
  end

  macro pending(description = nil, _source_file = __FILE__, _source_line = __LINE__, &block)
      {% if block.is_a?(Nop) %}
        {% if description.is_a?(Call) %}
          def %run
            {{description}}
          end
        {% else %}
          {% raise "Unrecognized syntax: `pending #{description}` at #{_source_file}:#{_source_line}" %}
        {% end %}
      {% else %}
        def %run
          {{block.body}}
        end
      {% end %}

      %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
      ::Spectator::SpecBuilder.add_pending_example(
        {{description.is_a?(StringLiteral) || description.is_a?(StringInterpolation) || description.is_a?(NilLiteral) ? description : description.stringify}},
        %source,
        {{@type.name}}
      ) { |test| test.as({{@type.name}}).%run }
    end

  macro skip(description = nil, &block)
      pending({{description}}) {{block}}
    end

  macro xit(description = nil, &block)
      pending({{description}}) {{block}}
    end
end
