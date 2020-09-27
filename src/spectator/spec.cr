require "./example"
require "./example_group"

module Spectator
  class Spec
    include Enumerable(Example)

    def initialize(@group : ExampleGroup)
    end

    def each
      @group.each do |node|
        if (example = node.as?(Example))
          yield example
        elsif (group = node.as?(ExampleGroup))
          # TODO
        end
      end
    end
  end
end
