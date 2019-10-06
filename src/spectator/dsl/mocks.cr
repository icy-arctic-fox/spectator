require "../double"

module Spectator::DSL
  macro double(name, &block)
    {% if block.is_a?(Nop) %}
      Double{{name.id}}.new(self)
    {% else %}
      class Double{{name.id}} < ::Spectator::Double
        private class Internal
          def initialize(@test : {{@type.id}})
          end

          forward_missing_to @test
        end

        def initialize(test : {{@type.id}})
          @internal = Internal.new(test)
        end

        {{block.body}}
      end
    {% end %}
  end
end
