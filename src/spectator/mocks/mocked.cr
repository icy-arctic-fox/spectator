require "./method_call"
require "./stubbable"

module Spectator
  module Mocked
    include Stubbable

    # Method called when a stub isn't found.
    #
    # The received message is captured in *call*.
    # Yield to call the original method's implementation.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    def _spectator_stub_fallback(call : MethodCall, &)
      if _spectator_stub_for_method?(call.method)
        Spectator::Log.info do # FIXME: Don't log to top-level Spectator logger (use mock or double logger).
          "Stubs are defined for #{call.method.inspect}, but none matched (no argument constraints met)."
        end

        raise UnexpectedMessage.new("#{_spectator_stubbed_name} received unexpected message #{call}")
      end

      yield # Uninteresting message, allow through.
    end

    # Method called when a stub isn't found.
    #
    # The received message is captured in *call*.
    # The expected return type is provided by *type*.
    # Yield to call the original method's implementation.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    def _spectator_stub_fallback(call : MethodCall, type, &)
      value = _spectator_stub_fallback(call) { yield }

      begin
        type.cast(value)
      rescue TypeCastError
        raise TypeCastError.new("#{_spectator_stubbed_name} received message #{call} and is attempting to return `#{value.inspect}`, but returned type must be `#{type}`.")
      end
    end

    # Method called when a stub isn't found.
    #
    # This is similar to `#_spectator_stub_fallback`,
    # but called when the original (un-stubbed) method isn't available.
    # The received message is captured in *call*.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    def _spectator_abstract_stub_fallback(call : MethodCall)
      Spectator::Log.info do # FIXME: Don't log to top-level Spectator logger (use mock or double logger).
        break unless _spectator_stub_for_method?(call.method)

        "Stubs are defined for #{call.method.inspect}, but none matched (no argument constraints met)."
      end

      raise UnexpectedMessage.new("#{_spectator_stubbed_name} received unexpected message #{call}")
    end

    # Method called when a stub isn't found.
    #
    # This is similar to `#_spectator_stub_fallback`,
    # but called when the original (un-stubbed) method isn't available.
    # The received message is captured in *call*.
    # The expected return type is provided by *type*.
    # The stubbed method returns the value returned by this method.
    # This method can also raise an error if it's impossible to return something.
    def _spectator_abstract_stub_fallback(call : MethodCall, type)
      value = _spectator_abstract_stub_fallback(call)

      begin
        type.cast(value)
      rescue TypeCastError
        raise TypeCastError.new("#{_spectator_stubbed_name} received message #{call} and is attempting to return `#{value.inspect}`, but returned type must be `#{type}`.")
      end
    end
  end
end
