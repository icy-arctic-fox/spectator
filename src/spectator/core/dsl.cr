module Spectator
  EXAMPLE_ALIASES = [] of Nil

  macro def_example_alias(name)
    {% EXAMPLE_ALIASES << name %}
  end

  module Core
    module DSL
      macro finished
        {% for example_alias in EXAMPLE_ALIASES %}
          macro {{example_alias.id}}(description, &block)
            {% verbatim do %}
              specify({{description}}) do {% if !block.args.empty? %} |{{block.args.splat}}| {% end %}
                {{yield}}
              end
            {% end %}
          end
        {% end %}
      end
    end
  end
end
