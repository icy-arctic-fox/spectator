module Spectator
  # Mix-in for defining hook methods.
  module Hooks
    # Defines various methods for adding hooks of a specific type.
    #
    # The *declaration* defines the name and type of hook.
    # It should be a type declaration in the form: `some_hook : ExampleHook`,
    # where `some_hook` is the name of the hook, and `ExampleHook` is type type.
    #
    # A default order can be specified by *order*.
    # The *order* argument must be *append* or *prepend*.
    # This indicates the order hooks are added by default when called by client code.
    #
    # Multiple methods are generated.
    # The primary methods will be named the same as the hook (from *declaration*).
    # These take a pre-built hook instance, or arguments to pass to the hook type's initializer.
    # The new hook is added a collection in the order specified by *order*.
    #
    # A private getter method is created so that the hooks can be accessed if needed.
    # The getter method has `_hooks` appended to the hook name.
    # For instance, if the *declaration* contains `important_thing`, then the getter is `important_thing_hooks`.
    #
    # Lastly, an optional block can be provided.
    # If given, a protected method will be defined with the block's contents.
    # This method typically operates on (calls) the hooks.
    # The private getter method mentioned above can be used to access the hooks.
    # Any block arguments will be used as argument in the method.
    # The method name has the prefix `call_` followed by the hook name.
    #
    # ```
    # define_hook important_event : ImportantHook do |example|
    #   important_event_hooks.each &.call(example)
    # end
    #
    # # ...
    #
    # important_event do |example|
    #   puts "An important event occurred for #{example}"
    # end
    # ```
    macro define_hook(declaration, order = :append, &block)
      {% if order.id == :append.id
           method = :push.id
         elsif order.id == :prepend.id
           method = :unshift.id
         else
           raise "Unknown hook order type - #{order}"
         end %}

      # Retrieves all registered hooks for {{declaration.var}}.
      protected getter {{declaration.var}}_hooks = Deque({{declaration.type}}).new

      # Registers a new "{{declaration.var}}" hook.
      # The hook will be {{order.id}}ed to the list.
      def {{declaration.var}}(hook : {{declaration.type}}) : Nil
        @{{declaration.var}}_hooks.{{method}}(hook)
      end

      # Registers a new "{{declaration.var}}" hook.
      # The hook will be {{order.id}}ed to the list.
      # A new hook will be created by passing args to `{{declaration.type}}.new`.
      def {{declaration.var}}(*args, **kwargs) : Nil
        hook = {{declaration.type}}.new(*args, **kwargs)
        {{declaration.var}}(hook)
      end

      # Registers a new "{{declaration.var}}" hook.
      # The hook will be {{order.id}}ed to the list.
      # A new hook will be created by passing args to `{{declaration.type}}.new`.
      def {{declaration.var}}(*args, **kwargs, &block) : Nil
        hook = {{declaration.type}}.new(*args, **kwargs, &block)
        {{declaration.var}}(hook)
      end

      {% if block %}
        # Handles calling all "{{declaration.var}}" hooks.
        protected def call_{{declaration.var}}({{block.args.splat}})
          {{block.body}}
        end
      {% end %}
    end
  end
end
