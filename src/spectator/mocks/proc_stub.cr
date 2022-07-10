require "../location"
require "./arguments"
require "./typed_stub"

module Spectator
  # Stub that responds with a value returned by calling a proc.
  class ProcStub(T) < TypedStub(T)
    # Invokes the stubbed implementation.
    def call(call : MethodCall) : T
      @proc.call(call.arguments)
    end

    # Creates the stub.
    def initialize(method : Symbol, @proc : Proc(AbstractArguments, T), constraint : AbstractArguments? = nil, location : Location? = nil)
      super(method, constraint, location)
    end

    # Creates the stub.
    def initialize(method : Symbol, constraint : AbstractArguments? = nil, location : Location? = nil, &block : Proc(AbstractArguments, T))
      initialize(method, block, constraint, location)
    end
  end
end
