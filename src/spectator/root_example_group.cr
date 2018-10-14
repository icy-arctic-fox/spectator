require "./example_group"

module Spectator
  class RootExampleGroup < ExampleGroup
    def what : String
      "ROOT"
    end

    def to_s(io)
      # ...
    end
  end
end
