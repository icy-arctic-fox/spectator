require "./config"
require "./config_builder"
require "./example"
require "./example_context_method"
require "./example_group"

module Spectator
  # Progressively builds a test spec.
  #
  # A stack is used to track the current example group.
  # Adding an example or group will nest it under the group at the top of the stack.
  class SpecBuilder
    Log = ::Spectator::Log.for(self)

    # Stack tracking the current group.
    # The bottom of the stack (first element) is the root group.
    # The root group should never be removed.
    # The top of the stack (last element) is the current group.
    # New examples should be added to the current group.
    @group_stack : Deque(ExampleGroup)

    # Configuration for the spec.
    @config : Config?

    # Creates a new spec builder.
    # A root group is pushed onto the group stack.
    def initialize
      root_group = ExampleGroup.new
      @group_stack = Deque(ExampleGroup).new
      @group_stack.push(root_group)
    end

    # Defines a new example group and pushes it onto the group stack.
    # Examples and groups defined after calling this method will be nested under the new group.
    # The group will be finished and popped off the stack when `#end_example` is called.
    #
    # The *name* is the name or brief description of the group.
    # This should be a symbol when describing a type - the type name is represented as a symbol.
    # Otherwise, a string should be used.
    #
    # The *source* optionally defined where the group originates in source code.
    #
    # The newly created group is returned.
    # It shouldn't be used outside of this class until a matching `#end_group` is called.
    def start_group(name, source = nil) : ExampleGroup
      Log.trace { "Start group: #{name.inspect} @ #{source}" }
      ExampleGroup.new(name, source, current_group).tap do |group|
        @group_stack << group
      end
    end

    # Completes a previously defined example group and pops it off the group stack.
    # Be sure to call `#start_group` and `#end_group` symmetically.
    #
    # The completed group will be returned.
    # At this point, it is safe to use the group.
    # All of its examples and sub-groups have been populated.
    def end_group : ExampleGroup
      Log.trace { "End group: #{current_group}" }
      raise "Can't pop root group" if root?

      @group_stack.pop
    end

    # Defines a new example.
    # The example is added to the group currently on the top of the stack.
    #
    # The *name* is the name or brief description of the example.
    # This should be a string or nil.
    # When nil, the example's name will be populated by the first expectation run inside of the test code.
    #
    # The *source* optionally defined where the example originates in source code.
    #
    # The *context* is an instance of the context the test code should run in.
    # See `Context` for more information.
    #
    # A block must be provided.
    # It will be yielded two arguments - the example created by this method, and the *context* argument.
    # The return value of the block is ignored.
    # It is expected that the test code runs when the block is called.
    #
    # The newly created example is returned.
    def add_example(name, source, context, &block : Example, Context ->) : Example
      Log.trace { "Add example: #{name} @ #{source}" }
      delegate = ExampleContextDelegate.new(context, block)
      Example.new(delegate, name, source, current_group)
      # The example is added to the current group by `Example` initializer.
    end

    # Sets the configuration of the spec.
    # This configuration controls how examples run.
    def config=(config)
      @config = config
    end

    # Constructs the test spec.
    # Returns the spec instance.
    #
    # Raises an error if there were not symmetrical calls to `#start_group` and `#end_group`.
    # This would indicate a logical error somewhere in Spectator or an extension of it.
    def build : Spec
      raise "Mismatched start and end groups" unless root?

      Spec.new(root_group, config)
    end

    # Checks if the current group is the root group.
    private def root?
      @group_stack.size == 1
    end

    # Retrieves the root group.
    private def root_group
      @group_stack.first
    end

    # Retrieves the current group, which is at the top of the stack.
    # This is the group that new examples should be added to.
    private def current_group
      @group_stack.last
    end

    # Retrieves the configuration.
    # If one wasn't previously set, a default configuration is used.
    private def config
      @config || ConfigBuilder.new.build
    end
  end
end
