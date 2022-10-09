require "./method_call"
require "./stub"

module Spectator
  # Defines stubbing functionality at the type level (classes and structs).
  #
  # This module is intended to be extended when a type includes `Stubbable`.
  module StubbedType
    private abstract def _spectator_stubs : Array(Stub)

    def _spectator_find_stub(call : MethodCall) : Stub?
      _spectator_stubs.find &.===(call)
    end

    def _spectator_stub_for_method?(method : Symbol) : Bool
      _spectator_stubs.any? { |stub| stub.method == method }
    end

    def _spectator_define_stub(stub : Stub) : Nil
      _spectator_stubs.unshift(stub)
    end

    def _spectator_remove_stub(stub : Stub) : Nil
      _spectator_stubs.delete(stub)
    end

    def _spectator_clear_stubs : Nil
      _spectator_stubs.clear
    end

    def _spectator_record_call(call : MethodCall) : Nil
      _spectator_calls << call
    end

    def _spectator_clear_calls : Nil
      _spectator_calls.clear
    end

    # Clears all previously defined calls and stubs.
    def _spectator_reset : Nil
      _spectator_clear_calls
      _spectator_clear_stubs
    end

    def _spectator_stub_fallback(call : MethodCall, &)
      Log.trace { "Fallback for #{call} - call original" }
      yield
    end

    def _spectator_stub_fallback(call : MethodCall, type, &)
      _spectator_stub_fallback(call) { yield }
    end

    def _spectator_abstract_stub_fallback(call : MethodCall)
      Log.info do
        break unless _spectator_stub_for_method?(call.method)

        "Stubs are defined for #{call.method.inspect}, but none matched (no argument constraints met)."
      end

      raise UnexpectedMessage.new("#{_spectator_stubbed_name} received unexpected message #{call}")
    end

    def _spectator_abstract_stub_fallback(call : MethodCall, type)
      _spectator_abstract_stub_fallback(call)
    end
  end
end
