require "./example_group"

module Spectator
  class RootExampleGroup < ExampleGroup
    def initialize(hooks)
      super("ROOT", nil, hooks)
    end

    def to_s(io)
      # ...
    end
  end
end
