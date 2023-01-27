require "./example_context_delegate"
require "./example_group"
require "./harness"
require "./location"
require "./node"
require "./pending_result"
require "./result"
require "./metadata"

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
    getter result : Result = PendingResult.new("Example not run")

    @name_proc : Proc(Example, String)?

    # Creates the example.
    # An instance to run the test code in is given by *context*.
    # The *entrypoint* defines the test code (typically inside *context*).
    # The *name* describes the purpose of the example.
    # The *location* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    # Note: The metadata will not be merged with the parent metadata.
    def initialize(@context : Context, @entrypoint : self ->,
                   name : String? = nil, location : Location? = nil,
                   @group : ExampleGroup? = nil, metadata = nil)
      super(name, location, metadata)

      # Ensure group is linked.
      group << self if group
    end

    # Creates the example.
    # An instance to run the test code in is given by *context*.
    # The *entrypoint* defines the test code (typically inside *context*).
    # The *name* describes the purpose of the example.
    # It can be a proc to be evaluated in the context of the example.
    # The *location* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    # Note: The metadata will not be merged with the parent metadata.
    def initialize(@context : Context, @entrypoint : self ->,
                   @name_proc : Example -> String, location : Location? = nil,
                   @group : ExampleGroup? = nil, metadata = nil)
      super(nil, location, metadata)

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
    # A set of *metadata* can be used for filtering and modifying example behavior.
    # Note: The metadata will not be merged with the parent metadata.
    def initialize(name : String? = nil, location : Location? = nil,
                   @group : ExampleGroup? = nil, metadata = nil, &block : self ->)
      super(name, location, metadata)

      @context = NullContext.new
      @entrypoint = block

      # Ensure group is linked.
      group << self if group
    end

    # Creates a pending example.
    # The *name* describes the purpose of the example.
    # It can be a `Symbol` to describe a type.
    # The *location* tracks where the example exists in source code.
    # The example will be assigned to *group* if it is provided.
    # A set of *metadata* can be used for filtering and modifying example behavior.
    # Note: The metadata will not be merged with the parent metadata.
    def self.pending(name : String? = nil, location : Location? = nil,
                     group : ExampleGroup? = nil, metadata = nil, reason = nil)
      # Add pending tag and reason if they don't exist.
      tags = {:pending => nil, :reason => reason}
      metadata = metadata ? metadata.merge(tags) { |_, v, _| v } : tags
      new(name, location, group, metadata) { nil }
    end

    # Executes the test case.
    # Returns the result of the execution.
    # The result will also be stored in `#result`.
    def run : Result
      Log.debug { "Running example: #{self}" }
      Log.warn { "Example already ran: #{self}" } if @finished

      if pending?
        Log.debug { "Skipping example #{self} - marked pending" }
        @finished = true
        return @result = PendingResult.new(pending_reason)
      end

      previous_example = @@current
      @@current = self

      begin
        @result = Harness.run do
          if proc = @name_proc
            self.name = proc.call(self)
          end

          @group.try(&.call_before_all)
          if (parent = @group)
            parent.call_around_each(procsy).call
          else
            run_internal
          end
          if (parent = @group)
            parent.call_after_all if parent.finished?
          end
        end
      ensure
        @@current = previous_example
        @finished = true
      end
    end

    private def run_internal
      if group = @group
        group.call_before_each(self)
        group.call_pre_condition(self)
      end
      Log.trace { "Running example code for: #{self}" }
      @entrypoint.call(self)
      @finished = true
      Log.trace { "Finished running example code for: #{self}" }
      if group = @group
        group.call_post_condition(self)
        group.call_after_each(self)
      end
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
    protected def with_context(klass, &)
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

    # Yields this example and all parent groups.
    def ascend(&)
      node = self
      while node
        yield node
        node = node.group?
      end
    end

    # Constructs the full name or description of the example.
    # This prepends names of groups this example is part of.
    def to_s(io : IO) : Nil
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
    def inspect(io : IO) : Nil
      super
      io << " - " << result
    end

    # Creates the JSON representation of the example,
    # which is just its name.
    def to_json(json : JSON::Builder)
      json.object do
        json.field("description", name? || "<anonymous>")
        json.field("full_description", to_s)
        if location = location?
          json.field("file_path", location.path)
          json.field("line_number", location.line)
        end
        @result.to_json(json) if @finished
      end
    end

    # Creates a procsy from this example that runs the example.
    def procsy
      Procsy.new(self) { run_internal }
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
      protected def with_context(klass, &)
        context = @example.cast_context(klass)
        with context yield
      end

      # Allow instance to behave like an example.
      forward_missing_to @example

      # Constructs the full name or description of the example.
      # This prepends names of groups this example is part of.
      def to_s(io : IO) : Nil
        @example.to_s(io)
      end
    end
  end
end
