require "../double"

module Spectator::DSL
  macro double(name, &block)
    {% if block.is_a?(Nop) %}
      Double{{name.id}}.new
    {% else %}
      class Double{{name.id}} < ::Spectator::Double
        {{block.body}}
      end
    {% end %}
  end
end
