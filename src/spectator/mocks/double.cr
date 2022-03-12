require "./arguments"
require "./method_call"
require "./stub"
require "./stubable"
require "./unexpected_message"
require "./value_stub"

module Spectator
  # Defines the name of a double or mock.
  #
  # When present on a stubbed type, this annotation indicates its name in output such as exceptions.
  # Must have one argument - the name of the double or mock.
  # This can be a symbol, string literal, or type name.
  annotation StubbedName; end

  # Stands in for an object for testing that a SUT calls expected methods.
  #
  # Handles all messages (method calls), but only responds to those configured.
  # Methods called that were not configured will raise `UnexpectedMessage`.
  abstract class Double
    include Stubable

    macro define(type_name, name = nil, **value_methods, &block)
      {% if name %}@[::Spectator::StubbedName({{name}})]{% end %}
      class {{type_name.id}} < {{@type.name}}
        {% for key, value in value_methods %}
          inject_stub def {{key.id}}
            {{value}}
          end
        {% end %}
        {% if block %}{{block.body}}{% end %}
      end
    end

    # Stores responses to messages (method calls).
    @stubs = [] of Stub

    private def _spectator_find_stub(call) : Stub?
      @stubs.find &.===(call)
    end

    # Utility returning the double's name as a string.
    private def _spectator_stubbed_name : String
      {% if anno = @type.annotation(StubbedName) %}
        "#<Double " + {{(anno[0] || :Anonymous.id).stringify}} + ">"
      {% else %}
        "#<Double Anonymous>"
      {% end %}
    end

    # "Hide" existing methods and methods from ancestors by overriding them.
    macro finished
      stub_all {{@type.name(generic_args: false)}}
    end

    # Handle all methods but only respond to configured messages.
    # Raises an `UnexpectedMessage` error for non-configures messages.
    macro method_missing(call)
      args = ::Spectator::Arguments.capture({{call.args.splat(", ")}}{% if call.named_args %}{{call.named_args.splat}}{% end %})
      call = ::Spectator::MethodCall.new({{call.name.symbolize}}, args)
      raise ::Spectator::UnexpectedMessage.new("#{_spectator_stubbed_name} received unexpected message :{{call.name}} with #{args}")
      nil # Necessary for compiler to infer return type as nil. Avoids runtime "can't execute ... `x` has no type errors".
    end
  end
end
