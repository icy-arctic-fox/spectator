require "../context"
require "../location"
require "./builder"
require "./metadata"

module Spectator::DSL
  # DSL methods for defining examples and test code.
  module Examples
    include Metadata

    # Defines a macro to generate code for an example.
    # The *name* is the name given to the macro.
    #
    # In addition, another macro is defined that marks the example as pending.
    # The pending macro is prefixed with 'x'.
    # For instance, `define_example :it` defines `it` and `xit`.
    #
    # Default tags can be provided with *tags* and *metadata*.
    # The tags are merged with parent groups.
    # Any items with falsey values from *metadata* remove the corresponding tag.
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

        _spectator_metadata(%metadata, :metadata, {{tags.splat(",")}} {{metadata.double_splat}})
        _spectator_metadata(\%metadata, %metadata, \{{tags.splat(",")}} \{{metadata.double_splat}})

        \{% if block %}
          \{% raise "Block argument count '{{name.id}}' must be 0..1" if block.args.size > 1 %}

          private def \%test(\{{block.args.splat}}) : Nil
            \{{block.body}}
          end

          ::Spectator::DSL::Builder.add_example(
            _spectator_example_name(\{{what}}),
            ::Spectator::Location.new(\{{block.filename}}, \{{block.line_number}}, \{{block.end_line_number}}),
            -> { new.as(::Spectator::Context) },
            \%metadata
          ) do |example|
            example.with_context(\{{@type.name}}) do
              \{% if block.args.empty? %}
                \%test
              \{% else %}
                \%test(example)
              \{% end %}
            end
          end

        \{% else %}
          ::Spectator::DSL::Builder.add_pending_example(
            _spectator_example_name(\{{what}}),
            ::Spectator::Location.new(\{{what.filename}}, \{{what.line_number}}),
            \%metadata,
            "Not yet implemented"
          )
        \{% end %}
      end

      define_pending_example :x{{name.id}}, skip: "Temporarily skipped with x{{name.id}}"
    end

    # Defines a macro to generate code for a pending example.
    # The *name* is the name given to the macro.
    #
    # The block for the example's content is discarded at compilation time.
    # This prevents issues with undefined methods, signature differences, etc.
    #
    # Default tags can be provided with *tags* and *metadata*.
    # The tags are merged with parent groups.
    # Any items with falsey values from *metadata* remove the corresponding tag.
    macro define_pending_example(name, *tags, **metadata)
      # Defines a pending example.
      #
      # If a block is given, it is treated as the code to test.
      # The block is provided the current example instance as an argument.
      #
      # The first argument names the example (test).
      # Typically, this specifies what is being tested.
      # It has no effect on the test and is purely used for output.
      # If omitted, a name is generated from the first assertion in the test.
      #
      # Tags can be specified by adding symbols (keywords) after the first argument.
      # Key-value pairs can also be specified.
      # Any falsey items will remove a previously defined tag.
      macro {{name.id}}(what = nil, *tags, **metadata, &block)
        \{% raise "Cannot use '{{name.id}}' inside of a test block" if @def %}
        \{% raise "A description or block must be provided. Cannot use '{{name.id}}' alone." unless what || block %}
        \{% raise "Block argument count '{{name.id}}' must be 0..1" if block && block.args.size > 1 %}

        _spectator_metadata(%metadata, :metadata, {{tags.splat(",")}} {{metadata.double_splat}})
        _spectator_metadata(\%metadata, %metadata, \{{tags.splat(",")}} \{{metadata.double_splat}})

        ::Spectator::DSL::Builder.add_pending_example(
          _spectator_example_name(\{{what}}),
          ::Spectator::Location.new(\{{(what || block).filename}}, \{{(what || block).line_number}}, \{{(what || block).end_line_number}}),
          \%metadata,
          \{% if !block %}"Not yet implemented"\{% end %}
        )
      end
    end

    # Inserts the correct representation of a example's name.
    # If *what* is a string, then it is dropped in as-is.
    # For anything else, it is stringified.
    # This is intended to be used to convert a description from the spec DSL to `Node#name`.
    private macro _spectator_example_name(what)
      {% if what.is_a?(StringLiteral) || what.is_a?(NilLiteral) %}
        {{what}}
      {% elsif what.is_a?(StringInterpolation) %}
        ->(example : ::Spectator::Example) do
          example.with_context(\{{@type.name}}) { {{what}} }
        end
      {% else %}
        {{what.stringify}}
      {% end %}
    end

    define_example :example

    define_example :it

    define_example :specify

    define_example :fexample, focus: true

    define_example :fit, focus: true

    define_example :fspecify, focus: true

    @[Deprecated("Behavior of pending blocks will change in Spectator v0.11.0. Use `skip` instead.")]
    define_pending_example :pending

    define_pending_example :skip
  end
end
