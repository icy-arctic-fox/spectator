require "./example_context_delegate"
require "./example_group"
require "./harness"
require "./location"
require "./node"
require "./pending_result"
require "./result"
require "./tags"

module Spectator
  # Standard example that runs a test case.
  class Example < Node
    # Currently running example.
    class_getter! current : Example

    # Group the node belongs to.
    getter! group : ExampleGroup

    # Assigns the node to the specified *group*.
    # This is an internal method and should only be called from `ExampleGroup`.
    # `ExampleGroup` manages the association of nodes to groups.
    protected setter group : ExampleGroup?

    # Indicates whether the example already ran.
    getter? finished : Bool = false

    # Result of the last time the example ran.
    # Is pending if the example hasn't run.
    getter result : Result = PendingResult.new

    # Creates the example.
    # An instance to run the test code in is given by *context*.
    # The *entrypoint* defines the test code (typically inside *context*).
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *location* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    # A set of *tags* can be used for filtering and modifying example behavior.
    # Note: The tags will not be merged with the parent tags.
    def initialize(@context : Context, @entrypoint : self ->,
                   name : String? = nil, location : Location? = nil,
                   @group : ExampleGroup? = nil, tags = Tags.new)
      super(name, location, tags)

      # Ensure group is linked.
      group << self if group
    end

    # Creates a dynamic example.
    # A block provided to this method will be called as-if it were the test code for the example.
    # The block will be given this example instance as an argument.
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *location* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    # A set of *tags* can be used for filtering and modifying example behavior.
    # Note: The tags will not be merged with the parent tags.
    def initialize(name : String? = nil, location : Location? = nil,
                   @group : ExampleGroup? = nil, tags = Tags.new, &block : self ->)
      super(name, location, tags)

      @context = NullContext.new
      @entrypoint = block

      # Ensure group is linked.
      group << self if group
    end

    # Executes the test case.
    # Returns the result of the execution.
    # The result will also be stored in `#result`.
    def run : Result
      Log.debug { "Running example #{self}" }
      Log.warn { "Example #{self} already ran" } if @finished

      if pending?
        Log.debug { "Skipping example #{self} - marked pending" }
        @finished = true
        return @result = PendingResult.new
      end

      previous_example = @@current
      @@current = self

      begin
        @result = Harness.run do
          @group.try(&.call_once_before_all)
          if (parent = @group)
            parent.call_around_each(self) { run_internal }
          else
            run_internal
          end
          if (parent = @group)
            parent.call_once_after_all if parent.finished?
          end
        end
      ensure
        @@current = previous_example
        @finished = true
      end
    end

    private def run_internal
      @group.try(&.call_before_each(self))
      @entrypoint.call(self)
      @finished = true
      @group.try(&.call_after_each(self))
    end

    # Executes code within the example's test context.
    # This is an advanced method intended for internal usage only.
    #
    # The *klass* defines the type of the test context.
    # This is typically only known by the code constructing the example.
    # An error will be raised if *klass* doesn't match the test context's type.
    # The block given to this method will be executed within the test context.
    #
    # The context casted to an instance of *klass* is provided as a block argument.
    #
    # TODO: Benchmark compiler performance using this method versus client-side casting in a proc.
    protected def with_context(klass)
      context = klass.cast(@context)
      with context yield
    end

    # Casts the example's test context to a specific type.
    # This is an advanced method intended for internal usage only.
    #
    # The *klass* defines the type of the test context.
    # This is typically only known by the code constructing the example.
    # An error will be raised if *klass* doesn't match the test context's type.
    #
    # The context casted to an instance of *klass* is returned.
    #
    # TODO: Benchmark compiler performance using this method versus client-side casting in a proc.
    protected def cast_context(klass)
      klass.cast(@context)
    end

    # Constructs the full name or description of the example.
    # This prepends names of groups this example is part of.
    def to_s(io)
      name = @name

      # Prefix with group's full name if the node belongs to a group.
      if (parent = @group)
        parent.to_s(io)

        # Add padding between the node names
        # only if the names don't appear to be symbolic.
        # Skip blank group names (like the root group).
        io << ' ' unless !parent.name? || # ameba:disable Style/NegatedConditionsInUnless
                         (parent.name?.is_a?(Symbol) && name.is_a?(String) &&
                         (name.starts_with?('#') || name.starts_with?('.')))
      end

      super
    end

    # Exposes information about the example useful for debugging.
    def inspect(io)
      super
      io << ' ' << result
    end

    # Creates the JSON representation of the example,
    # which is just its name.
    def to_json(json : ::JSON::Builder)
      json.string(to_s)
    end

    # Creates a procsy from this example and the provided block.
    def procsy(&block : ->)
      Procsy.new(self, &block)
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

      # Executes code within the example's test context.
      # This is an advanced method intended for internal usage only.
      #
      # The *klass* defines the type of the test context.
      # This is typically only known by the code constructing the example.
      # An error will be raised if *klass* doesn't match the test context's type.
      # The block given to this method will be executed within the test context.
      #
      # TODO: Benchmark compiler performance using this method versus client-side casting in a proc.
      protected def with_context(klass)
        context = @example.cast_context(klass)
        with context yield
      end

      # Allow instance to behave like an example.
      forward_missing_to @example
    end
  end
end
