require "../../spectator_test"
require "../test_values"
require "../test_wrapper"

module Spectator::SpecBuilder
  class ExampleBuilder
    alias FactoryMethod = TestValues -> ::SpectatorTest

    def initialize(@description : String, @source : Source, @builder : FactoryMethod, @runner : TestMethod)
    end

    def build(group)
      test = @builder.call(group.context.values)
      wrapper = TestWrapper.new(@description, @source, test, @runner)
      RunnableExample.new(group, wrapper).as(ExampleComponent)
    end
  end
end
