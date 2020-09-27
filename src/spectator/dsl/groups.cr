require "../source"
require "./builder"

module Spectator::DSL
  # DSL methods and macros for creating example groups.
  # This module should be included as a mix-in.
  module Groups
    macro define_example_group(name)
      # Defines a new example group.
      # The *what* argument is a name or description of the group.
      #
      # TODO: Handle string interpolation in example and group names.
      macro {{name.id}}(what, &block)
        class Group%group < \{{@type.id}}
          _spectator_group_subject(\{{what}})

          ::Spectator::DSL::Builder.start_group(
            _spectator_group_name(\{{what}}),
            ::Spectator::Source.new(\{{block.filename}}, \{{block.line_number}})
          )

          \{{block.body}}

          ::Spectator::DSL::Builder.end_group
        end
      end
    end

    # Inserts the correct representation of a group's name.
    # If *what* appears to be a type name, it will be symbolized.
    # If it's a string, then it is dropped in as-is.
    # For anything else, it is stringified.
    # This is intended to be used to convert a description from the spec DSL to `ExampleNode#name`.
    private macro _spectator_group_name(what)
      {% if (what.is_a?(Generic) ||
              what.is_a?(Path) ||
              what.is_a?(TypeNode) ||
              what.is_a?(Union)) &&
              (described_type = what.resolve?).is_a?(TypeNode) %}
        {{what.symbolize}}
      {% elsif what.is_a?(StringLiteral) ||
                 what.is_a?(StringInterpolation) ||
                 what.is_a?(NilLiteral) %}
        {{what}}
      {% else %}
        {{what.stringify}}
      {% end %}
    end

    # Defines the implicit subject for the test context.
    # If *what* is a type, then the `described_class` method will be defined.
    # Additionally, the implicit subject is set to an instance of *what* if it's not a module.
    #
    # There is no common macro type that has the `#resolve?` method.
    # Also, `#responds_to?` can't be used in macros.
    # So the large if statement in this macro is used to look for type signatures.
    private macro _spectator_group_subject(what)
      {% if (what.is_a?(Generic) ||
              what.is_a?(Path) ||
              what.is_a?(TypeNode) ||
              what.is_a?(Union)) &&
              (described_type = what.resolve?).is_a?(TypeNode) %}
        private def described_class
          {{described_type}}
        end

        private def _spectator_implicit_subject
          {% if described_type < Reference || described_type < Value %}
            described_class.new
          {% else %}
            described_class
          {% end %}
        end
      {% else %}
        private def _spectator_implicit_subject
          {{what}}
        end
      {% end %}
    end

    define_example_group :example_group

    define_example_group :describe

    define_example_group :context
  end

  macro sample(collection, count = nil, _source_file = __FILE__, _source_line = __LINE__, &block)
      {% name = block.args.empty? ? :value.id : block.args.first.id %}

      def %collection
        {{collection}}
      end

      def %to_a
        {% if count %}
          %collection.first({{count}})
        {% else %}
          %collection.to_a
        {% end %}
      end

      class Context%sample < {{@type.id}}
        %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
        ::Spectator::SpecBuilder.start_sample_group({{collection.stringify}}, %source, :%sample, {{name.stringify}}) do |values|
          sample = {{@type.id}}.new(values)
          sample.%to_a
        end

        def {{name}}
          @spectator_test_values.get_value(:%sample, typeof(%to_a.first))
        end

        {{block.body}}

        ::Spectator::SpecBuilder.end_group
      end
    end

  macro random_sample(collection, count = nil, _source_file = __FILE__, _source_line = __LINE__, &block)
      {% name = block.args.empty? ? :value.id : block.args.first.id %}

      def %collection
        {{collection}}
      end

      def %to_a
        {% if count %}
          %collection.first({{count}})
        {% else %}
          %collection.to_a
        {% end %}
      end

      class Context%sample < {{@type.id}}
        %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
        ::Spectator::SpecBuilder.start_sample_group({{collection.stringify}}, %source, :%sample, {{name.stringify}}) do |values|
          sample = {{@type.id}}.new(values)
          collection = sample.%to_a
          {% if count %}
            collection.sample({{count}}, ::Spectator.random)
          {% else %}
            collection.shuffle(::Spectator.random)
          {% end %}
        end

        def {{name}}
          @spectator_test_values.get_value(:%sample, typeof(%to_a.first))
        end

        {{block.body}}

        ::Spectator::SpecBuilder.end_group
      end
    end

  macro given(*assignments, &block)
      context({{assignments.splat.stringify}}) do
        {% for assignment in assignments %}
          let({{assignment.target}}) { {{assignment.value}} }
        {% end %}

        {% # Trick to get the contents of the block as an array of nodes.
# If there are multiple expressions/statements in the block,
# then the body will be a `Expressions` type.
# If there's only one expression, then the body is just that.
 body = if block.is_a?(Nop)
          raise "Missing block for 'given'"
        elsif block.body.is_a?(Expressions)
          # Get the expressions, which is already an array.
          block.body.expressions
        else
          # Wrap the expression in an array.
          [block.body]
        end %}

        {% for item in body %}
          # If the item starts with "it", then leave it as-is.
          # Otherwise, prefix it with "it"
          # and treat it as the one-liner "it" syntax.
          {% if item.is_a?(Call) && item.name == :it.id %}
            {{item}}
          {% else %}
            it {{item}}
          {% end %}
        {% end %}
      end
    end
end
