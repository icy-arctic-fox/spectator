require "./example"
require "./example_group"
require "./example_iterator"

module Spectator
  # Contains examples to be tested.
  class Spec
    def initialize(@root : ExampleGroup)
    end

    def run
      examples = ExampleIterator.new(@root).to_a
      Runner.new(examples).run
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
