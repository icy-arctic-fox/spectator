require "./example_context_delegate"
require "./example_group"
require "./example_node"
require "./pass_result"
require "./pending_result"
require "./result"
require "./source"

module Spectator
  # Standard example that runs a test case.
  class Example < ExampleNode
    # Indicates whether the example already ran.
    getter? finished : Bool = false

    # Retrieves the result of the last time the example ran.
    getter result : Result = PendingResult.new

    # Creates the example.
    # The *delegate* contains the test context and method that runs the test case.
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *source* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    def initialize(@delegate : ExampleContextDelegate,
                   name : String? = nil, source : Source? = nil, group : ExampleGroup? = nil)
      super(name, source, group)
    end

    # Creates a dynamic example.
    # A block provided to this method will be called as-if it were the test code for the example.
    # The block will be given this example instance as an argument.
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *source* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    def initialize(name : String? = nil, source : Source? = nil, group : ExampleGroup? = nil, &block : Example -> _)
      @delegate = ExampleContextDelegate.null(&block)
    end

    # Executes the test case.
    # Returns the result of the execution.
    # The result will also be stored in `#result`.
    def run : Result
      runner = Runner.new(self, @delegate)
      @result = runner.run
    ensure
      @finished = true
    end

    # Exposes information about the example useful for debugging.
    def inspect(io)
      # Full example name.
      io << '"'
      to_s(io)
      io << '"'

      # Add source if it's available.
      if (sourse = self.source)
        io << " @ "
        io << source
      end

      io << result
    end

    # Responsible for executing example code and reporting results.
    private struct Runner
      # Creates the runner.
      # *example* is the example being tested.
      # The *delegate* is the entrypoint of the example's test code.
      def initialize(@example : Example, @delegate : ExampleContextDelegate)
      end

      # Executes the example's test code and produces a result.
      def run : Result
        Log.debug { "Running example #{@example}" }
        elapsed = Time.measure do
          @delegate.call(@example)
        end
        PassResult.new(elapsed)
      end
    end
  end
end
