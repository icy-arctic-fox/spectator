require "./abstract_example_factory"

module Spectator
  module DSL
    class ExampleFactory(T) < AbstractExampleFactory
      def build(locals : Hash(Symbol, ValueWrapper)) : Example
        T.new(locals)
      end
    end
  end
end
