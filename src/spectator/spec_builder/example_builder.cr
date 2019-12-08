require "../../spectator_test"
require "../test_values"
require "../test_wrapper"

module Spectator::SpecBuilder
  abstract class ExampleBuilder
    alias FactoryMethod = TestValues -> ::SpectatorTest

    def initialize(@description : String, @source : Source, @builder : FactoryMethod, @runner : TestMethod)
    end

    abstract def build(group) : ExampleComponent

    private def build_test_wrapper(group)
      test = @builder.call(group.context.values)
      TestWrapper.new(@description, @source, test, @runner)
    end
  end
end
