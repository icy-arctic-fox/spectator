require "../../spectator_test"
require "../test_wrapper"

module Spectator::SpecBuilder
  class ExampleBuilder
    alias FactoryMethod = -> ::SpectatorTest

    def initialize(@description : String, @source : Source, @builder : FactoryMethod, @runner : TestMethod)
    end

    def build(group)
      test = @builder.call
      wrapper = TestWrapper.new(@description, @source, test, @runner)
      RunnableExample.new(group, wrapper).as(ExampleComponent)
    end
  end
end
