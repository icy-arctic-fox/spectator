require "./example_context_delegate"

module Spectator
  # Mix-in for managing events and hooks.
  # This module is intended to be included by `ExampleGroup`.
  module Events
    # Defines an event for an example group.
    # This event typically runs before or after an example group finishes.
    # No contextual information (or example) is provided to the hooks.
    # The *name* defines the name of the event.
    # This must be unique across all events.
    # Three methods are defined - one to add a hook and the others to trigger the event which calls every hook.
    # One trigger method, prefixed with *call_* will always call the event hooks.
    # The other trigger method, prefixed with *call_once_* will only call the event hooks on the first invocation.
    private macro group_event(name, &block)
      @{{name.id}}_hooks = Deque(->).new
      @{{name.id}}_called = Atomic::Flag.new

      # Defines a hook for the *{{name.id}}* event.
      # The block of code given to this method is invoked when the event occurs.
      def {{name.id}}(&block) : Nil
        @{{name.id}}_hooks << block
      end

      # Signals that the *{{name.id}}* event has occurred.
      # All hooks associated with the event will be called.
      def call_{{name.id}} : Nil
        {{block.args.first}} = @{{name.id}}_hooks
        {{yield}}
      end

      # Signals that the *{{name.id}}* event has occurred.
      # Only calls the hooks if the event hasn't been triggered before by this method.
      # Returns true if the hooks were called and false if they weren't (called previously).
      def call_once_{{name.id}} : Bool
        first = @{{name.id}}_called.test_and_set
        call_{{name.id}} if first
        first
      end
    end

    # Defines an event for an example.
    # This event typically runs before or after an example finishes.
    # The current example is provided to the hooks.
    # The *name* defines the name of the event.
    # This must be unique across all events.
    # Three methods are defined - two to add a hook and the other to trigger the event which calls every hook.
    # A hook can be added with an `ExampleContextDelegate` or a block that accepts an example (no context).
    private macro example_event(name, &block)
      @{{name.id}}_hooks = Deque(Example ->).new

      # Defines a hook for the *{{name.id}}* event.
      # The block of code given to this method is invoked when the event occurs.
      # The current example is provided as a block argument.
      def {{name.id}}(&block : Example ->) : Nil
        @{{name.id}}_hooks << block
      end

      # Signals that the *{{name.id}}* event has occurred.
      # All hooks associated with the event will be called.
      # The *example* should be the current example.
      def call_{{name.id}}({{block.args[1]}}) : Nil
        {{block.args.first}} = @{{name.id}}_hooks
        {{yield}}
      end
    end
  end
end
