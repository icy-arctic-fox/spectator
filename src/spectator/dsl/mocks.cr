require "../double"

module Spectator::DSL
  macro double(name, &block)
    {% if block.is_a?(Nop) %}
      Double{{name.id}}.new(@spectator_test_values)
    {% else %}
      class Double{{name.id}} < ::Spectator::Double
        class Internal < {{@type.id}}
        end

        def initialize(test_values : ::Spectator::TestValues)
          @internal = Internal.new(test_values)
        end

        {{block.body}}
      end
    {% end %}
  end
end
