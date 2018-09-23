module Spectator
  module DSL
    abstract class AbstractExampleFactory
      abstract def build(locals : Hash(Symbol, ValueWrapper)) : Example
    end
  end
end
