require "../spec_builder"

module Spectator
  module DSL
    macro context(what, &block)
      class Context%context < {{@type.id}}
        {%
          description = if what.is_a?(StringLiteral) || what.is_a?(StringInterpolation)
                          if what.starts_with?("#") || what.starts_with?(".")
                            what.id.symbolize
                          else
                            what
                          end
                        else
                          what.symbolize
                        end
        %}

        %source = ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
        ::Spectator::SpecBuilder.start_group({{description}}, %source)

        # Oddly, `#resolve?` can return a constant's value, which isn't a TypeNode.
        # Ensure `described_class` and `subject` are only set for real types (is a `TypeNode`).
        {% if (what.is_a?(Path) || what.is_a?(Generic)) && (described_type = what.resolve?).is_a?(TypeNode) %}
          macro described_class
            {{what}}
          end

          subject do
            {% if described_type < Reference || described_type < Value %}
              described_class.new
            {% else %}
              described_class
            {% end %}
          end
        {% else %}
          def _spectator_implicit_subject(*args)
            {{what}}
          end
        {% end %}

        {{block.body}}

        ::Spectator::SpecBuilder.end_group
      end
    end

    macro describe(what, &block)
      context({{what}}) {{block}}
    end

    macro sample(collection, count = nil, &block)
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
        %source = ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
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

    macro random_sample(collection, count = nil, &block)
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
        %source = ::Spectator::Source.new({{block.filename}}, {{block.line_number}})
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
end
