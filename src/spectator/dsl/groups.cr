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

    macro sample(what, &block)
      {% block_arg = block.args.empty? ? :value.id : block.args.first.id %}
      class Sample%sample < {{@type.id}}
        def %collection
          {{what}}
        end
      end

      class Context%sample < {{@type.id}}
        ::Spectator::SpecBuilder.start_sample_group({{what.stringify}}, :%sample) do |values|
          sample = Sample%sample.new(values)
          sample.%collection.to_a
        end

        def {{block_arg}}
          1
        end

        {{block.body}}

        ::Spectator::SpecBuilder.end_group
      end
    end
  end
end
