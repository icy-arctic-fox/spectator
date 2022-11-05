require "./abstract_arguments"
require "./arguments"
require "./method_call"
require "./stub_modifiers"

module Spectator
  # Untyped response to a method call (message).
  abstract class Stub
    include StubModifiers

    # Name of the method this stub is for.
    getter method : Symbol

    # Arguments the method must have been called with to provide this response.
    # Is nil when there's no constraint - only the method name must match.
    getter constraint : AbstractArguments?

    # Location the stub was defined.
    getter location : Location?

    # Creates the base of the stub.
    def initialize(@method : Symbol, @constraint : AbstractArguments? = nil, @location : Location? = nil)
    end

    # String representation of the stub, formatted as a method call.
    def message(io : IO) : Nil
      io << "#" << method << (constraint || "(any args)")
    end

    # String representation of the stub, formatted as a method call.
    def message
      String.build do |str|
        message(str)
      end
    end

    # String representation of the stub, formatted as a method definition.
    def to_s(io : IO) : Nil
      message(io)
    end

    # Checks if a method call should receive the response from this stub.
    def ===(call : MethodCall)
      return false if method != call.method
      return true unless constraint = @constraint

      constraint === call.arguments
    end
  end
end
