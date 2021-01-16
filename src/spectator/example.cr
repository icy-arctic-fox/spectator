require "./example_context_delegate"
require "./example_group"
require "./harness"
require "./pending_result"
require "./result"
require "./source"
require "./spec_node"

module Spectator
  # Standard example that runs a test case.
  class Example < SpecNode
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
    def initialize(@context : Context, @entrypoint : self ->,
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
    def initialize(name : String? = nil, source : Source? = nil, group : ExampleGroup? = nil, &block : self ->)
      @context = NullContext.new
      @entrypoint = block
    end

    # Executes the test case.
    # Returns the result of the execution.
    # The result will also be stored in `#result`.
    def run : Result
      Log.debug { "Running example #{self}" }
      Log.warn { "Example #{self} already ran" } if @finished

      previous_example = @@current
      @@current = self

      begin
        @result = Harness.run do
          if (parent = group?)
            parent.call_around_each(self) { run_internal }
          else
            run_internal
          end
        end
      ensure
        @@current = previous_example
        @finished = true
      end
    end

    private def run_internal
      run_before_hooks
      run_test
      run_after_hooks
    end

    private def run_before_hooks : Nil
      return unless (parent = group?)

      parent.call_once_before_all
      parent.call_before_each(self)
    end

    private def run_after_hooks : Nil
      return unless (parent = group?)

      parent.call_after_each(self)
      parent.call_once_after_all if parent.finished?
    end

    private def run_test : Nil
      @entrypoint.call(self)
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
      context = klass.cast(@context)
      with context yield
    end

    # Constructs the full name or description of the example.
    # This prepends names of groups this example is part of.
    def to_s(io)
      if name?
        super
      else
        io << "<anonymous>"
      end
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

    # Wraps an example to behave like a `Proc`.
    # This is typically used for an *around_each* hook.
    # Invoking `#call` or `#run` will run the example.
    struct Procsy
      # Underlying example that will run.
      getter example : Example

      # Creates the example proxy.
      # The *example* should be run eventually.
      # The *proc* defines the block of code to run when `#call` or `#run` is invoked.
      def initialize(@example : Example, &@proc : ->)
      end

      # Invokes the proc.
      def call : Nil
        @proc.call
      end

      # Invokes the proc.
      def run : Nil
        @proc.call
      end

      # Creates a new procsy for a block and the example from this instance.
      def wrap(&block : ->) : self
        self.class.new(@example, &block)
      end

      # Allow instance to behave like an example.
      forward_missing_to @example
    end
  end
end
