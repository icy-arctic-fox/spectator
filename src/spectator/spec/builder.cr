require "../config"
require "../example"
require "../example_context_method"
require "../example_group"
require "../iterative_example_group"
require "../spec"
require "../metadata"

module Spectator
  class Spec
    # Progressively builds a test spec.
    #
    # A stack is used to track the current example group.
    # Adding an example or group will nest it under the group at the top of the stack.
    class Builder
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

      # Constructs the test spec.
      # Returns the spec instance.
      #
      # Raises an error if there were not symmetrical calls to `#start_group` and `#end_group`.
      # This would indicate a logical error somewhere in Spectator or an extension of it.
      def build : Spec
        raise "Mismatched start and end groups" unless root?

        Spec.new(root_group, config)
      end

      # Defines a new example group and pushes it onto the group stack.
      # Examples and groups defined after calling this method will be nested under the new group.
      # The group will be finished and popped off the stack when `#end_example` is called.
      #
      # The *name* is the name or brief description of the group.
      # This should be a symbol when describing a type - the type name is represented as a symbol.
      # Otherwise, a string should be used.
      #
      # The *location* optionally defined where the group originates in source code.
      #
      # A set of *metadata* can be used for filtering and modifying example behavior.
      # For instance, adding a "pending" tag will mark tests as pending and skip execution.
      #
      # The newly created group is returned.
      # It shouldn't be used outside of this class until a matching `#end_group` is called.
      def start_group(name, location = nil, metadata = Metadata.new) : ExampleGroup
        Log.trace { "Start group: #{name.inspect} @ #{location}; metadata: #{metadata}" }
        ExampleGroup.new(name, location, current_group, metadata).tap do |group|
          @group_stack << group
        end
      end

      # Defines a new iterative example group and pushes it onto the group stack.
      # Examples and groups defined after calling this method will be nested under the new group.
      # The group will be finished and popped off the stack when `#end_example` is called.
      #
      # The *collection* is the set of items to iterate over.
      # Child nodes in this group will be executed once for every item in the collection.
      #
      # The *location* optionally defined where the group originates in source code.
      #
      # A set of *metadata* can be used for filtering and modifying example behavior.
      # For instance, adding a "pending" tag will mark tests as pending and skip execution.
      #
      # The newly created group is returned.
      # It shouldn't be used outside of this class until a matching `#end_group` is called.
      def start_iterative_group(collection, location = nil, metadata = Metadata.new) : ExampleGroup
        Log.trace { "Start iterative group: #{typeof(collection)} @ #{location}; metadata: #{metadata}" }
        IterativeExampleGroup.new(collection, location, current_group, metadata).tap do |group|
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
      # The *location* optionally defined where the example originates in source code.
      #
      # The *context* is an instance of the context the test code should run in.
      # See `Context` for more information.
      #
      # A set of *metadata* can be used for filtering and modifying example behavior.
      # For instance, adding a "pending" tag will mark the test as pending and skip execution.
      #
      # A block must be provided.
      # It will be yielded two arguments - the example created by this method, and the *context* argument.
      # The return value of the block is ignored.
      # It is expected that the test code runs when the block is called.
      #
      # The newly created example is returned.
      def add_example(name, location, context, metadata = Metadata.new, &block : Example -> _) : Example
        Log.trace { "Add example: #{name} @ #{location}; metadata: #{metadata}" }
        Example.new(context, block, name, location, current_group, metadata)
        # The example is added to the current group by `Example` initializer.
      end

      # Defines a new pending example.
      # The example is added to the group currently on the top of the stack.
      #
      # The *name* is the name or brief description of the example.
      # This should be a string or nil.
      # When nil, the example's name will be an anonymous example reference.
      #
      # The *location* optionally defined where the example originates in source code.
      #
      # A set of *metadata* can be used for filtering and modifying example behavior.
      # For instance, adding a "pending" tag will mark the test as pending and skip execution.
      # A default *reason* can be given in case the user didn't provide one.
      #
      # The newly created example is returned.
      def add_pending_example(name, location, metadata = Metadata.new, reason = nil) : Example
        Log.trace { "Add pending example: #{name} @ #{location}; metadata: #{metadata}" }
        Example.pending(name, location, current_group, metadata, reason)
        # The example is added to the current group by `Example` initializer.
      end

      # Attaches a hook to be invoked before any and all examples in the current group.
      def before_all(hook)
        Log.trace { "Add before_all hook #{hook}" }
        current_group.add_before_all_hook(hook)
      end

      # Defines a block of code to execute before any and all examples in the current group.
      def before_all(&block)
        Log.trace { "Add before_all hook" }
        current_group.before_all(&block)
      end

      # Attaches a hook to be invoked before every example in the current group.
      # The current example is provided as a block argument.
      def before_each(hook)
        Log.trace { "Add before_each hook #{hook}" }
        current_group.add_before_each_hook(hook)
      end

      # Defines a block of code to execute before every example in the current group.
      # The current example is provided as a block argument.
      def before_each(&block : Example -> _)
        Log.trace { "Add before_each hook block" }
        current_group.before_each(&block)
      end

      # Attaches a hook to be invoked after any and all examples in the current group.
      def after_all(hook)
        Log.trace { "Add after_all hook #{hook}" }
        current_group.add_after_all_hook(hook)
      end

      # Defines a block of code to execute after any and all examples in the current group.
      def after_all(&block)
        Log.trace { "Add after_all hook" }
        current_group.after_all(&block)
      end

      # Attaches a hook to be invoked after every example in the current group.
      # The current example is provided as a block argument.
      def after_each(hook)
        Log.trace { "Add after_each hook #{hook}" }
        current_group.add_after_each_hook(hook)
      end

      # Defines a block of code to execute after every example in the current group.
      # The current example is provided as a block argument.
      def after_each(&block : Example -> _)
        Log.trace { "Add after_each hook" }
        current_group.after_each(&block)
      end

      # Attaches a hook to be invoked around every example in the current group.
      # The current example in procsy form is provided as a block argument.
      def around_each(hook)
        Log.trace { "Add around_each hook #{hook}" }
        current_group.add_around_each_hook(hook)
      end

      # Defines a block of code to execute around every example in the current group.
      # The current example in procsy form is provided as a block argument.
      def around_each(&block : Example -> _)
        Log.trace { "Add around_each hook" }
        current_group.around_each(&block)
      end

      # Builds the configuration to use for the spec.
      # A `Config::Builder` is yielded to the block provided to this method.
      # That builder will be used to create the configuration.
      def configure(& : Config::Builder -> _) : Nil
        builder = Config::Builder.new
        yield builder
        @config = builder.build
      end

      # Sets the configuration of the spec.
      # This configuration controls how examples run.
      def config=(config)
        @config = config
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
      private def config : Config
        @config || Config.default
      end
    end
  end
end
