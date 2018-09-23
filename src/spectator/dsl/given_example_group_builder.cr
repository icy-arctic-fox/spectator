require "./example_group_builder"

module Spectator
  module DSL
    class GivenExampleGroupBuilder < ExampleGroupBuilder

      def initialize(what : String, @collection : Array(ValueWrapper))
        super(what)
      end

      def build(locals : Hash(Symbol, ValueWrapper)) : ExampleGroup
        raise NotImplementedError
      end
    end
  end
end
