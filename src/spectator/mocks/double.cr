require "./unexpected_message"
require "./stub"
require "./stubable"
require "./value_stub"
require "./arguments"
require "./method_call"

module Spectator
  annotation DoubleName; end

  # Stands in for an object for testing that a SUT calls expected methods.
  #
  # Handles all messages (method calls), but only responds to those configured.
  # Methods called that were not configured will raise `UnexpectedMessage`.
  abstract class Double
    include Stubable

    macro define(type_name, name = nil, **value_methods, &block)
      {% if name %}@[DoubleName({{name}})]{% end %}
      class {{type_name.id}} < {{@type.name}}
        {% for key, value in value_methods %}
          stub def {{key.id}}
            {{value}}
          end
        {% end %}
        {% if block %}{{block.body}}{% end %}
      end
      {% debug %}
    end

    # Stores responses to messages (method calls).
    @stubs = [] of Stub

    private def _spectator_find_stub(call) : Stub?
      @stubs.find &.===(call)
    end

    # Utility returning the double's name as a string.
    private def _spectator_double_name : String
      {% if anno = @type.annotation(DoubleName) %}
        "#<Double {{anno[0]}}"
      {% else %}
        "#<Double Anonymous>"
      {% end %}
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
            {{meth.args.splat(",")}}
            {% if meth.double_splat %}**{{meth.double_splat}}, {% end %}
            {% if meth.block_arg %}&{{meth.block_arg}}{% elsif meth.accepts_block? %}&{% end %}
          ){% if meth.return_type %} : {{meth.return_type}}{% end %}{% if !meth.free_vars.empty? %} forall {{meth.free_vars.splat}}{% end %}
            # Capture call information.
            %args = Arguments.capture(
              {{meth.args.map(&.internal_name).splat}}{% if !meth.args.empty? %}, {% end %}
              {% if meth.double_splat %}**{{meth.double_splat}}, {% end %}
            )
            %call = MethodCall.new({{meth.name.symbolize}}, %args)

            # Find a suitable stub.
            if %stub = @stubs.find &.===(%call)
              # Return configured response.
              %stub.value
            else
              # Response not configured for this method/message.
              raise UnexpectedMessage.new("#{_spectator_double_name} received unexpected message :{{meth.name}} (masking ancestor) with #{%args}")
            end
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
      arguments = ::Spectator::Arguments.capture({{call.args.splat(", ")}}{% if call.named_args %}{{call.named_args.splat}}{% end %})
      call = ::Spectator::MethodCall.new({{call.name.symbolize}}, arguments)
      raise ::Spectator::UnexpectedMessage.new("#{_spectator_double_name} received unexpected message :{{call.name}} with #{arguments}")
      {% debug %}
    end
  end
end
