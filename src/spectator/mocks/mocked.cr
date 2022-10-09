require "./method_call"
require "./stub"
require "./stubbable"
require "./unexpected_message"

module Spectator
  # Mix-in used for mocked types.
  #
  # Bridges functionality between mocks and stubs
  # Implements the abstracts methods from `Stubbable`.
  #
  # Types including this module will need to implement `#_spectator_stubs`.
  # It should return a mutable list of stubs.
  # This is used to store the stubs for the mocked type.
  #
  # Additionally, the `#_spectator_calls` (getter with no arguments) must be implemented.
  # It should return a mutable list of method calls.
  # This is used to store the calls to stubs for the mocked type.
  module Mocked
    include Stubbable

    # Retrieves an mutable collection of stubs.
    abstract def _spectator_stubs

    def _spectator_define_stub(stub : ::Spectator::Stub) : Nil
      _spectator_stubs.unshift(stub)
    end

    def _spectator_remove_stub(stub : Stub) : Nil
      _spectator_stubs.delete(stub)
    end

    def _spectator_clear_stubs : Nil
      _spectator_stubs.clear
    end

    private def _spectator_find_stub(call : ::Spectator::MethodCall) : ::Spectator::Stub?
      _spectator_stubs.find &.===(call)
    end

    def _spectator_stub_for_method?(method : Symbol) : Bool
      _spectator_stubs.any? { |stub| stub.method == method }
    end

    def _spectator_record_call(call : MethodCall) : Nil
      _spectator_calls << call
    end

    def _spectator_calls(method : Symbol) : Enumerable(MethodCall)
      _spectator_calls.select { |call| call.method == method }
    end

    def _spectator_clear_calls : Nil
      _spectator_calls.clear
    end

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
