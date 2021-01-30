require "../context"
require "../source"
require "./builder"

module Spectator::DSL
  # DSL methods for defining examples and test code.
  module Examples
    # Defines a macro to generate code for an example.
    # The *name* is the name given to the macro.
    # TODO: Mark example as pending if block is omitted.
    macro define_example(name)
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
      macro {{name.id}}(what = nil, *tags, **metadata, &block)
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}
        \{% raise "A description or block must be provided. Cannot use '{{name.id}}' alone." unless what || block %}
        \{% raise "Block argument count '{{name.id}}' hook must be 0..1" if block.args.size > 1 %}

        def self.\%metadata
          \{% if tags.empty? && metadata.empty? %}
            _spectator_metadata
          \{% else %}
            _spectator_metadata.merge(
              \{% for tag in tags %}
              \{{tag.id.stringify}}: true,
              \{% end %}
              \{{metadata.double_splat}}
            )
          \{% end %}
        end

        def \%test(\{{block.args.splat}}) : Nil
          \{{block.body}}
        end

        ::Spectator::DSL::Builder.add_example(
          _spectator_example_name(\{{what}}),
          ::Spectator::Source.new(\{{block.filename}}, \{{block.line_number}}),
          \{{@type.name}}.new.as(::Spectator::Context),
          \{{@type.name}}.\%metadata
        ) do |example|
          example.with_context(\{{@type.name}}) do
            \{% if block.args.empty? %}
              \%test
            \{% else %}
              \%test(example.unwrap_metadata(typeof(\{{@type.name}}.\%metadata)))
            \{% end %}
          end
        end
      end
    end

    # Inserts the correct representation of a example's name.
    # If *what* is a string, then it is dropped in as-is.
    # For anything else, it is stringified.
    # This is intended to be used to convert a description from the spec DSL to `Spec::Node#name`.
    private macro _spectator_example_name(what)
      {% if what.is_a?(StringLiteral) ||
              what.is_a?(StringInterpolation) ||
              what.is_a?(NilLiteral) %}
        {{what}}
      {% else %}
        {{what.stringify}}
      {% end %}
    end

    define_example :example

    define_example :it

    define_example :specify

    # TODO: pending, skip, and xit
  end
end
