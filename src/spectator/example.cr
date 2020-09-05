require "./context_delegate"
require "./example_base"
require "./example_group"
require "./result"
require "./source"

module Spectator
  # Standard example that runs a test case.
  class Example < ExampleBase
    # Indicates whether the example already ran.
    getter? finished : Bool = false

    # Retrieves the result of the last time the example ran.
    getter! result : Result

    # Creates the example.
    # The *delegate* contains the test context and method that runs the test case.
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *source* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    def initialize(@delegate : ContextDelegate,
      name : String | Symbol? = nil, source : Source? = nil, group : ExampleGroup? = nil)
      super(name, source, group)
    end

    # Executes the test case.
    # Returns the result of the execution.
    # The result will also be stored in `#result`.
    def run : Result
      raise NotImplementedError.new("#run")
    end
  end
end
