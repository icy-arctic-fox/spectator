require "../context"
require "../source"
require "./builder"
require "./tags"

module Spectator::DSL
  # DSL methods for defining examples and test code.
  module Examples
    include Tags

    # Defines a macro to generate code for an example.
    # The *name* is the name given to the macro.
    #
    # Default tags can be provided with *tags* and *metadata*.
    # The tags are merged with parent groups.
    # Any items with falsey values from *metadata* remove the corresponding tag.
    #
    # TODO: Mark example as pending if block is omitted.
    macro define_example(name, *tags, **metadata)
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
      #
      # Tags can be specified by adding symbols (keywords) after the first argument.
      # Key-value pairs can also be specified.
      # Any falsey items will remove a previously defined tag.
      macro {{name.id}}(what = nil, *tags, **metadata, &block)
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}
        \{% raise "A description or block must be provided. Cannot use '{{name.id}}' alone." unless what || block %}
        \{% raise "Block argument count '{{name.id}}' hook must be 0..1" if block.args.size > 1 %}

        _spectator_tags(%tags, :tags, {{tags.splat(",")}} {{metadata.double_splat}})
        _spectator_tags(\%tags, %tags, \{{tags.splat(",")}} \{{metadata.double_splat}})

        private def \%test(\{{block.args.splat}}) : Nil
          \{{block.body}}
        end

        ::Spectator::DSL::Builder.add_example(
          _spectator_example_name(\{{what}}),
          ::Spectator::Source.new(\{{block.filename}}, \{{block.line_number}}),
          new.as(::Spectator::Context),
          \%tags
        ) do |example|
          example.with_context(\{{@type.name}}) do
            \{% if block.args.empty? %}
              \%test
            \{% else %}
              \%test(example)
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

    define_example :xexample, :pending

    define_example :xspecify, :pending

    define_example :xit, :pending

    define_example :skip, :pending
  end
end
