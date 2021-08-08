require "./config"
require "./example"
require "./example_builder"
require "./example_context_method"
require "./example_group"
require "./example_group_builder"
require "./hooks"
require "./iterative_example_group_builder"
require "./pending_example_builder"
require "./spec"
require "./metadata"

module Spectator
  # Progressively builds a test spec.
  #
  # A stack is used to track the current example group.
  # Adding an example or group will nest it under the group at the top of the stack.
  class SpecBuilder
    Log = ::Spectator::Log.for(self)

    delegate before_all,
      prepend_before_all,
      after_all,
      append_after_all,
      before_each,
      prepend_before_each,
      after_each,
      append_after_each,
      around_each,
      prepend_around_each,
      to: current

    # Stack tracking the current group.
    # The bottom of the stack (first element) is the root group.
    # The root group should never be removed.
    # The top of the stack (last element) is the current group.
    # New examples should be added to the current group.
    @stack : Deque(ExampleGroupBuilder)

    # Creates a new spec builder.
    # A root group is pushed onto the group stack.
    def initialize(@config : Config)
      root = ExampleGroupBuilder.new
      @stack = Deque(ExampleGroupBuilder).new
      @stack.push(root)
    end

    # Constructs the test spec.
    # Returns the spec instance.
    #
    # Raises an error if there were not symmetrical calls to `#start_group` and `#end_group`.
    # This would indicate a logical error somewhere in Spectator or an extension of it.
    def build : Spec
      raise "Mismatched start and end groups" unless root?

      group = root.build
      apply_config_hooks(group)
      Spec.new(group, @config)
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
    def start_group(name, location = nil, metadata = Metadata.new) : Nil
      Log.trace { "Start group: #{name.inspect} @ #{location}; metadata: #{metadata}" }
      builder = ExampleGroupBuilder.new(name, location, metadata)
      current << builder
      @stack.push(builder)
    end

    # Defines a new iterative example group and pushes it onto the group stack.
    # Examples and groups defined after calling this method will be nested under the new group.
    # The group will be finished and popped off the stack when `#end_example` is called.
    #
    # The *collection* is the set of items to iterate over.
    # Child nodes in this group will be executed once for every item in the collection.
    # The *name* should be a string representation of *collection*.
    # The *iterator* is an optional name given to a single item in *collection*.
    #
    # The *location* optionally defined where the group originates in source code.
    #
    # A set of *metadata* can be used for filtering and modifying example behavior.
    # For instance, adding a "pending" tag will mark tests as pending and skip execution.
    def start_iterative_group(collection, name, iterator = nil, location = nil, metadata = Metadata.new) : Nil
      Log.trace { "Start iterative group: #{name} (#{typeof(collection)}) @ #{location}; metadata: #{metadata}" }
      builder = IterativeExampleGroupBuilder.new(collection, name, iterator, location, metadata)
      current << builder
      @stack.push(builder)
    end

    # Completes a previously defined example group and pops it off the group stack.
    # Be sure to call `#start_group` and `#end_group` symmetically.
    def end_group : Nil
      Log.trace { "End group: #{current}" }
      raise "Can't pop root group" if root?

      @stack.pop
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
    # The *context_builder* is a proc that creates a context the test code should run in.
    # See `Context` for more information.
    #
    # A set of *metadata* can be used for filtering and modifying example behavior.
    # For instance, adding a "pending" tag will mark the test as pending and skip execution.
    #
    # A block must be provided.
    # It will be yielded two arguments - the example created by this method, and the *context* argument.
    # The return value of the block is ignored.
    # It is expected that the test code runs when the block is called.
    def add_example(name, location, context_builder, metadata = Metadata.new, &block : Example -> _) : Nil
      Log.trace { "Add example: #{name} @ #{location}; metadata: #{metadata}" }
      current << ExampleBuilder.new(context_builder, block, name, location, metadata)
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
    def add_pending_example(name, location, metadata = Metadata.new, reason = nil) : Nil
      Log.trace { "Add pending example: #{name} @ #{location}; metadata: #{metadata}" }
      current << PendingExampleBuilder.new(name, location, metadata, reason)
    end

    # Registers a new "before_suite" hook.
    # The hook will be appended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def before_suite(*args, **kwargs) : Nil
      root.before_all(*args, **kwargs)
    end

    # Registers a new "before_suite" hook.
    # The hook will be appended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def before_suite(*args, **kwargs, &block) : Nil
      root.before_all(*args, **kwargs, &block)
    end

    # Registers a new "before_suite" hook.
    # The hook will be prepended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def prepend_before_suite(*args, **kwargs) : Nil
      root.prepend_before_all(*args, **kwargs)
    end

    # Registers a new "before_suite" hook.
    # The hook will be prepended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def prepend_before_suite(*args, **kwargs, &block) : Nil
      root.prepend_before_all(*args, **kwargs, &block)
    end

    # Registers a new "after_suite" hook.
    # The hook will be prepended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def after_suite(*args, **kwargs) : Nil
      root.before_all(*args, **kwargs)
    end

    # Registers a new "after_suite" hook.
    # The hook will be prepended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def after_suite(*args, **kwargs, &block) : Nil
      root.after_all(*args, **kwargs, &block)
    end

    # Registers a new "after_suite" hook.
    # The hook will be appended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def append_after_suite(*args, **kwargs) : Nil
      root.append_after_all(*args, **kwargs)
    end

    # Registers a new "after_suite" hook.
    # The hook will be appended to the list.
    # A new hook will be created by passing args to `ExampleGroupHook.new`.
    def append_after_suite(*args, **kwargs, &block) : Nil
      root.append_after_all(*args, **kwargs, &block)
    end

    # Checks if the current group is the root group.
    private def root?
      @stack.size == 1
    end

    # Retrieves the root group.
    private def root
      @stack.first
    end

    # Retrieves the current group, which is at the top of the stack.
    # This is the group that new examples should be added to.
    private def current
      @stack.last
    end

    # Retrieves the configuration.
    # If one wasn't previously set, a default configuration is used.
    private def config : Config
      @config || Config.default
    end

    # Copy all hooks from config to top-level group.
    private def apply_config_hooks(group)
      config.before_suite_hooks.reverse_each { |hook| group.prepend_before_all(hook) }
      config.after_suite_hooks.each { |hook| group.append_after_all(hook) }
      config.before_each_hooks.reverse_each { |hook| group.prepend_before_each(hook) }
      config.after_each_hooks.each { |hook| group.append_after_each(hook) }
      config.around_each_hooks.reverse_each { |hook| group.prepend_around_each(hook) }

      # `before_all` and `after_all` hooks from config are slightly different.
      # They are applied to every top-level group (groups just under root).
      group.each do |node|
        next unless node.is_a?(Hooks)

        config.before_all_hooks.reverse_each { |hook| node.prepend_before_all(hook.dup) }
        config.after_all_hooks.each { |hook| node.append_after_all(hook.dup) }
      end
    end
  end
end
