require "./unexpected_message"

module Spectator
  # Stands in for an object for testing that a SUT calls expected methods.
  #
  # Handles all messages (method calls), but only responds to those configured.
  # Methods called that were not configured will raise `UnexpectedMessage`.
  class Double(Messages)
    # Creates a double with pre-configures responses.
    # A *name* can be provided, otherwise it is considered an anonymous double.
    def initialize(@name : String? = nil, **@messages : **Messages)
    end

    # Utility returning the double's name as a string.
    private def _spectator_double_name : String
      if name = @name
        "#<Double #{name.inspect}>"
      else
        "#<Double Anonymous>"
      end
    end

    # Redefines all methods on a type to conditionally respond to messages.
    # Methods will raise `UnexpectedMessage` if they're called when they shouldn't be.
    # Otherwise, they'll return the configured response.
    # TODO: Better error for type mismatch
    private macro _spectator_mask_methods(type_name)
      {% type = type_name.resolve %}
      {% if type.superclass %}
        _spectator_mask_methods({{type.superclass}})
      {% end %}

      {% for meth in type.methods %}
        {% if !meth.abstract? && !DSL::RESERVED_KEYWORDS.includes?(meth.name.symbolize) %}
          {% if meth.visibility != :public %}{{meth.visibility.id}}{% end %} def {{meth.receiver}}{{meth.name}}(
            {{meth.args.splat}}{% if !meth.args.empty? %}, {% end %}
            {% if meth.double_splat %}**{{meth.double_splat}}, {% end %}
            {% if meth.block_arg %}&{{meth.block_arg}}{% elsif meth.accepts_block? %}&{% end %}
          ){% if meth.return_type %} : {{meth.return_type}}{% end %}{% if !meth.free_vars.empty? %} forall {{meth.free_vars.splat}}{% end %}
            \{% if type = Messages[{{meth.name.symbolize}}] %}
              {% if meth.return_type %}
                \{% if type <= {{meth.return_type}} %}
                  # Return type appears to match configured type.
                  # Respond with configured value.
                  @messages[{{meth.name.symbolize}}].as({{meth.return_type}})
                \{% else %}
                  # Return type doesn't match configured type.
                  # Can't return the configured response as the type mismatches (won't compile).
                  # Raise at runtime to provide additional information.
                  raise "Type mismatch {{meth.name}} : {{meth.return_type}}"
                \{% end %}
              {% else %}
                # No return type restriction, return configured response.
                @messages[{{meth.name.symbolize}}]
              {% end %}
            \{% else %}
              # Response not configured for this method/message.
              raise UnexpectedMessage.new("#{_spectator_double_name} received unexpected message :{{meth.name}} (masking ancestor) with (<TODO: ARGS>).")
            \{% end %}
          end
        {% end %}
      {% end %}
    end

    # "Hide" existing methods and methods from ancestors by overriding them.
    macro finished
      _spectator_mask_methods({{@type.name(generic_args: false)}})
    end

    # Handle all methods but only respond to configured messages.
    # Raises an `UnexpectedMessage` error for non-configures messages.
    macro method_missing(call)
      \{% if Messages.keys.includes?({{call.name.symbolize}}.id) %}
        # Return configured response.
        @messages[{{call.name.symbolize}}]
      \{% else %}
        # Response not configured for this method/message.
        raise UnexpectedMessage.new("#{_spectator_double_name} received unexpected message :{{call.name}} with (<TODO: ARGS>).")
      \{% end %}
    end
  end
end
