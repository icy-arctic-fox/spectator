require "./double"
require "./method_call"
require "./stubbed_name"
require "./unexpected_message"

module Spectator
  # Stands in for an object for testing that a SUT calls expected methods.
  #
  # Handles all messages (method calls), but only responds to those configured.
  # Methods called that were not configured will return self.
  # Doubles should be defined with the `#define` macro.
  #
  # Use `#_spectator_define_stub` to override behavior of a method in the double.
  # Only methods defined in the double's type can have stubs.
  # New methods are not defines when a stub is added that doesn't have a matching method name.
  abstract class NullDouble < Double
    # Returns the double's name formatted for user output.
    private def _spectator_stubbed_name : String
      {% if anno = @type.annotation(StubbedName) %}
        "#<NullDouble " + {{(anno[0] || :Anonymous.id).stringify}} + ">"
      {% else %}
        "#<NullDouble Anonymous>"
      {% end %}
    end

    private def _spectator_abstract_stub_fallback(call : MethodCall)
      if _spectator_stub_for_method?(call.method)
        Log.info { "Stubs are defined for #{call.method.inspect}, but none matched (no argument constraints met)." }
        raise UnexpectedMessage.new("#{inspect} received unexpected message #{call}")
      else
        Log.trace { "Fallback for #{call} - return self" }
        self
      end
    end

    # Specialization that matches when the return type matches self.
    private def _spectator_abstract_stub_fallback(call : MethodCall, _type : self)
      _spectator_abstract_stub_fallback(call)
    end

    # Default implementation that raises a `TypeCastError` since the return type isn't self.
    private def _spectator_abstract_stub_fallback(call : MethodCall, type)
      if _spectator_stub_for_method?(call.method)
        Log.info { "Stubs are defined for #{call.method.inspect}, but none matched (no argument constraints met)." }
        raise UnexpectedMessage.new("#{inspect} received unexpected message #{call}")
      else
        raise TypeCastError.new("#{inspect} received message #{call} and is attempting to return `self`, but returned type must be `#{type}`.")
      end
    end

    # Handles all undefined messages.
    # Returns stubbed values if available, otherwise delegates to `#_spectator_abstract_stub_fallback`.
    macro method_missing(call)
      # Capture information about the call.
      %args = ::Spectator::Arguments.capture({{call.args.splat(", ")}}{{call.named_args.splat if call.named_args}})
      %call = ::Spectator::MethodCall.new({{call.name.symbolize}}, %args)
      _spectator_record_call(%call)

      Log.trace { "#{inspect} got undefined method `#{%call}{% if call.block %} { ... }{% end %}`" }

      self
    end
  end
end
