require "./item"

module Spectator
  module Core
    module Context
      abstract def add_child(child : Item) : Nil
    end

    struct ContextDSL(T)
      private getter context : T

      def initialize(@context : T)
      end
    end
  end

  def self.context
    root_example_group
  end
end
