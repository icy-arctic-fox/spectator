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
      ExampleIterator.new(@root).to_a.tap do |examples|
        if @config.randomize?
          random = if (seed = @config.random_seed)
            Random.new(seed)
          else
            Random.new
          end
          examples.shuffle!(random)
        end
      end
    end

    private struct Runner
      def initialize(@examples : Array(Example))
      end

      def run
        @examples.each(&.run)
      end
    end
  end
end
