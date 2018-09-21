module Spectator
  abstract class ExampleFactory
    abstract def build(locals : Hash(Symbol, ValueWrapper)) : Example
  end
end
