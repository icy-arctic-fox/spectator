require "./config"
require "./example"
require "./example_group"
require "./example_iterator"

module Spectator
  # Contains examples to be tested.
  class Spec
    def initialize(@root : ExampleGroup, @config : Config)
    end

    def run
      Runner.new(examples).run
    end

    # Generates a list of examples to run.
    # The order of the examples are also sorted based on the configuration.
    private def examples
      examples = ExampleIterator.new(@root).to_a
      @config.shuffle!(examples)
    end
  end
end

require "./spec/*"
