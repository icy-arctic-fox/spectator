module Spectator
  module DSL
    class ExampleFactory
      def initialize(@example_type : Example.class)
      end

      def build(locals : Hash(Symbol, ValueWrapper)) : Example
        @example_type.new(locals)
      end
    end
  end
end
