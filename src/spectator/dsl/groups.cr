require "../spec_builder"

module Spectator
  module DSL
    macro context(what, &block)
      class Context%context < {{@type.id}}
        ::Spectator::SpecBuilder.start_group(
          {% if what.is_a?(StringLiteral) %}
            {% if what.starts_with?("#") || what.starts_with?(".") %}
              {{what.id.symbolize}}
            {% else %}
              {{what}}
            {% end %}
          {% else %}
            {{what.symbolize}}
          {% end %}
        )

        {{block.body}}

        ::Spectator::SpecBuilder.end_group
      end
    end

    macro describe(what, &block)
      context({{what}}) {{block}}
    end

    macro sample(collection, &block)
      {% block_arg = block.args.empty? ? :value.id : block.args.first.id %}

      def %collection
        {{collection}}
      end

      def %to_a
        %collection.to_a
      end

      class Context%sample < {{@type.id}}
        ::Spectator::SpecBuilder.start_sample_group({{collection.stringify}}, :%sample, {{block_arg.stringify}}) do |values|
          sample = {{@type.id}}.new(values)
          sample.%to_a
        end

        def {{block_arg}}
          @spectator_test_values.get_value(:%sample, typeof(%to_a.first))
        end

        {{block.body}}

        ::Spectator::SpecBuilder.end_group
      end
    end
  end
end
