require "../spec_builder"

module Spectator
  module DSL
    macro context(what, _source_file = __FILE__, _source_line = __LINE__, &block)
      class Context%context < {{@type.id}}
        {%
          description = if what.is_a?(StringLiteral)
                          if what.starts_with?("#") || what.starts_with?(".")
                            what.id.symbolize
                          else
                            what
                          end
                        else
                          what.symbolize
                        end
        %}

        %source = ::Spectator::Source.new({{_source_file}}, {{_source_line}})
        ::Spectator::SpecBuilder.start_group({{description}}, %source)

        {% if what.is_a?(Path) || what.is_a?(Generic) %}
          macro described_class
            {{what}}
          end

          def subject(*args)
            described_class.new(*args)
          end
        {% end %}

        {{block.body}}

        ::Spectator::SpecBuilder.end_group
      end
    end

    macro describe(what, &block)
      context({{what}}) {{block}}
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
end
