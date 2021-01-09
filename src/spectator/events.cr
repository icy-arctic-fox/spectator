require "./example_context_delegate"

module Spectator
  # Mix-in for managing events and hooks.
  # This module is intended to be included by `ExampleGroup`.
  module Events
    # Defines an event for an example group.
    # This event typically runs before or after an example group finishes.
    # No contextual information (or example) is provided to the hooks.
    #
    # The *name* defines the name of the event.
    # This must be unique across all events, not just group events.
    # Three public methods are defined - one to add a hook and the others to trigger the event which calls every hook.
    # One trigger method, prefixed with *call_* will always call the event hooks.
    # The other trigger method, prefixed with *call_once_* will only call the event hooks on the first invocation.
    #
    # A block must be provided to this macro.
    # The block defines the logic for invoking all of the hooks.
    # A single argument is yielded to the block - the set of hooks for the event.
    #
    # ```
    # group_event some_hook do |hooks|
    #   hooks.each(&.call)
    # end
    # ```
    private macro group_event(name, &block)
      @%hooks = Deque(->).new
      @%called = Atomic::Flag.new

      # Defines a hook for the *{{name.id}}* event.
      # The block of code given to this method is invoked when the event occurs.
      def {{name.id}}(&block) : Nil
        @%hooks << block
      end

      # Signals that the *{{name.id}}* event has occurred.
      # All hooks associated with the event will be called.
      def call_{{name.id}} : Nil
        %block(@%hooks)
      end

      # Signals that the *{{name.id}}* event has occurred.
      # Only calls the hooks if the event hasn't been triggered before by this method.
      # Returns true if the hooks were called and false if they weren't (called previously).
      def call_once_{{name.id}} : Bool
        first = @%called.test_and_set
        call_{{name.id}} if first
        first
      end

      # Logic specific to invoking the *{{name.id}}* hook.
      private def %block({{block.args.splat}})
        {{block.body}}
      end
    end

    # Defines an event for an example.
    # This event typically runs before or after an example finishes.
    # The current example is provided to the hooks.
    #
    # The *name* defines the name of the event.
    # This must be unique across all events.
    # Two public methods are defined - one to add a hook and the other to trigger the event which calls every hook.
    #
    # A block must be provided to this macro.
    # The block defines the logic for invoking all of the hooks.
    # Two arguments are yielded to the block - the set of hooks for the event, and the current example.
    #
    # ```
    # example_event some_hook do |hooks, example|
    #   hooks.each(&.call(example))
    # end
    # ```
    private macro example_event(name, &block)
      @%hooks = Deque(Example ->).new

      # Defines a hook for the *{{name.id}}* event.
      # The block of code given to this method is invoked when the event occurs.
      # The current example is provided as a block argument.
      def {{name.id}}(&block : Example ->) : Nil
        @%hooks << block
      end

      # Signals that the *{{name.id}}* event has occurred.
      # All hooks associated with the event will be called.
      # The *example* should be the current example.
      def call_{{name.id}}(example : Example) : Nil
        %block(@%hooks, example)
      end

      # Logic specific to invoking the *{{name.id}}* hook.
      private def %block({{block.args.splat}})
        {{block.body}}
      end
    end
  end
end
