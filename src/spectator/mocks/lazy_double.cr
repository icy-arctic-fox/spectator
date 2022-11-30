require "../label"
require "./arguments"
require "./double"
require "./method_call"
require "./stub"
require "./value_stub"

module Spectator
  # Stands in for an object for testing that a SUT calls expected methods.
  #
  # Handles all messages (method calls), but only responds to those configured.
  # Methods called that were not configured will raise `UnexpectedMessage`.
  #
  # Use `#_spectator_define_stub` to override behavior of a method in the double.
  # Only methods defined in the double's type can have stubs.
  # New methods are not defines when a stub is added that doesn't have a matching method name.
  class LazyDouble(Messages) < Double
    @name : String?

    def initialize(_spectator_double_name = nil, _spectator_double_stubs = [] of Stub, **@messages : **Messages)
      @name = _spectator_double_name.try &.inspect
      message_stubs = messages.map do |method, value|
        ValueStub.new(method, value)
      end

      super(_spectator_double_stubs + message_stubs)
    end

    # Defines a stub to change the behavior of a method in this double.
    #
    # NOTE: Defining a stub for a method not defined in the double's type raises an error.
    protected def _spectator_define_stub(stub : Stub) : Nil
      return super if Messages.types.has_key?(stub.method)

      raise "Can't define stub #{stub} on lazy double because it wasn't initially defined."
    end

    # Returns the double's name formatted for user output.
    private def _spectator_stubbed_name : String
      @name || "Anonymous"
    end

    private def _spectator_stub_fallback(call : MethodCall, &)
      if _spectator_stub_for_method?(call.method)
        Log.info { "Stubs are defined for #{call.method.inspect}, but none matched (no argument constraints met)." }
        raise UnexpectedMessage.new("#{inspect} received unexpected message #{call}")
      else
        Log.trace { "Fallback for #{call} - call original" }
        yield
      end
    end

    # Handles all messages.
    macro method_missing(call)
      # Capture information about the call.
      %args = ::Spectator::Arguments.capture({{call.args.splat(", ")}}{{call.named_args.splat if call.named_args}})
      %call = ::Spectator::MethodCall.new({{call.name.symbolize}}, %args)
      _spectator_record_call(%call)

      Log.trace { "#{inspect} got undefined method `#{%call}{% if call.block %} { ... }{% end %}`" }

      # Attempt to find a stub that satisfies the method call and arguments.
      if %stub = _spectator_find_stub(%call)
        # Cast the stub or return value to the expected type.
        # This is necessary to match the expected return type of the original message.
        \{% if Messages.keys.includes?({{call.name.symbolize}}) %}
          _spectator_cast_stub_value(%stub, %call, \{{Messages[{{call.name.symbolize}}.id]}})
        \{% else %}
          # A method that was not defined during initialization was stubbed.
          # Even though all stubs will have a #call method, the compiler doesn't seem to agree.
          # Assert that it will (this should never fail).
          raise TypeCastError.new("Stub has no value") unless %stub.responds_to?(:call)

          # Return the value of the stub as-is.
          # Might want to give a warning here, as this may produce a "bloated" union of all known stub types.
          %stub.call(%call)
        \{% end %}
      else
        # A stub wasn't found, invoke the fallback logic.
        \{% if Messages.keys.includes?({{call.name.symbolize}}.id) %}
          # Pass along the message type and a block to invoke it.
          _spectator_stub_fallback(%call, \{{Messages[{{call.name.symbolize}}.id]}}) { @messages[{{call.name.symbolize}}] }
        \{% else %}
          # Message received for a methods that isn't stubbed nor defined when initialized.
          _spectator_abstract_stub_fallback(%call)
          nil # Necessary for compiler to infer return type as nil. Avoids runtime "can't execute ... `x` has no type errors".
        \{% end %}
      end
    end
  end
end
