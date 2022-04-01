require "./arguments"
require "./typed_stub"

module Spectator
  # Stub that responds with a static value.
  class ValueStub(T) < TypedStub(T)
    # Invokes the stubbed implementation.
    def call(_call : MethodCall) : T
      @value
    end

    # Creates the stub.
    def initialize(method : Symbol, @value : T, constraint : AbstractArguments? = nil)
      super(method, constraint)
    end
  end
end
