require "./double"
require "./method_call"
require "./stubbed_name"

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

    private def _spectator_stub_fallback(call : MethodCall, &)
      self
    end

    private def _spectator_stub_fallback(call : MethodCall, type : self, &)
      self
    end

    private def _spectator_stub_fallback(call : MethodCall, type, &)
      yield
    end

    private def _spectator_abstract_stub_fallback(call : MethodCall)
      self
    end

    private def _spectator_abstract_stub_fallback(call : MethodCall, type : self)
      self
    end

    private def _spectator_abstract_stub_fallback(call : MethodCall, type)
      raise TypeCastError.new("#{_spectator_stubbed_name} received message #{call} and is attempting to return `self`, but returned type must be `#{type}`.")
    end

    # Handle all methods but only respond to configured messages.
    # Returns self.
    macro method_missing(_call)
      self
    end
  end
end
