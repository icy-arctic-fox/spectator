require "./example_context_delegate"
require "./example_group"
require "./example_node"
require "./harness"
require "./pending_result"
require "./result"
require "./source"

module Spectator
  # Standard example that runs a test case.
  class Example < ExampleNode
    # Currently running example.
    class_getter! current : Example

    # Indicates whether the example already ran.
    getter? finished : Bool = false

    # Retrieves the result of the last time the example ran.
    getter result : Result = PendingResult.new

    # Creates the example.
    # An instance to run the test code in is given by *context*.
    # The *entrypoint* defines the test code (typically inside *context*).
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *source* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    def initialize(@context : Context, @entrypoint : ExampleContextMethod,
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
      @context = NullContext.new
      @entrypoint = block
    end

    # Executes the test case.
    # Returns the result of the execution.
    # The result will also be stored in `#result`.
    def run : Result
      @@current = self
      Log.debug { "Running example #{self}" }
      Log.warn { "Example #{self} already ran" } if @finished
      @result = Harness.run { @entrypoint.call(self, @context) }
    ensure
      @@current = nil
      @finished = true
    end

    # Executes code within the example's test context.
    # This is an advanced method intended for internal usage only.
    #
    # The *klass* defines the type of the test context.
    # This is typically only known by the code constructing the example.
    # An error will be raised if *klass* doesn't match the test context's type.
    # The block given to this method will be executed within the test context.
    #
    # TODO: Benchmark compiler performance using this method versus client-side casting in a proc.
    def with_context(klass)
      context = klass.cast(@delegate.context)
      with context yield
    end

    # Exposes information about the example useful for debugging.
    def inspect(io)
      # Full example name.
      io << '"'
      to_s(io)
      io << '"'

      # Add source if it's available.
      if (source = self.source)
        io << " @ "
        io << source
      end

      io << result
    end
  end
end
