module Spectator
  module Core::DSL
  end

  macro def_example_alias(name)
    module ::Spectator::Core::DSL
      macro {{name.id}}(description, &block)
        {% verbatim do %}
          specify({{description}}) do {% if !block.args.empty? %} |{{block.args.splat}}| {% end %}
            {{yield}}
          end
        {% end %}
      end
    end
  end
end
