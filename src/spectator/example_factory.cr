module Spectator
  abstract class ExampleFactory
    abstract def build : Example
  end
end
