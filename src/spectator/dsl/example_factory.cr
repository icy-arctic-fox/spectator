module Spectator
  module DSL
    class ExampleFactory
      def initialize(@example_type : Example.class)
      end

      def build(group : ExampleGroup, locals : Hash(Symbol, ValueWrapper)) : Example
        @example_type.new(group, locals)
      end
    end
  end
end
