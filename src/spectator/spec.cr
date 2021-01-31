require "./config"
require "./example"
require "./example_group"
require "./test_suite"

module Spectator
  # Contains examples to be tested.
  class Spec
    def initialize(@root : ExampleGroup, @config : Config)
    end

    def run(filter : ExampleFilter)
      suite = TestSuite.new(@root, filter)
      Runner.new(suite, @config).run
    end
  end
end

require "./spec/*"
