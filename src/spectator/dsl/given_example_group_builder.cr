require "./example_group_builder"

module Spectator
  module DSL
    class GivenExampleGroupBuilder < ExampleGroupBuilder

      def initialize(what : String, @collection : Array(ValueWrapper))
        super(what)
      end

      def build : Array(Example)
        # TODO
        Array(Example).new
      end
    end
  end
end
