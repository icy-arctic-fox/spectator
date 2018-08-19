require "./example"

module Spectator
  class ExampleGroup
    protected getter examples : Array(Example)

    def initialize(@examples)
    end
  end
end
