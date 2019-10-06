module Spectator
  abstract class Double
    macro stub(definition, &block)
      delegate {{definition.name.id}}, to: @internal

      private class Internal
        def {{definition.name.id}}({{definition.args.splat}})
          {% if definition.block.is_a?(Nop) %}
            {% if block.is_a?(Nop) %}
              raise "Stubbed method called without being allowed"
            {% else %}
              {{block.body}}
            {% end %}
          {% else %}
            {{definition.block.body}}
          {% end %}
        end
      end
    end
  end
end
