require "./arguments"
require "./typed_stub"

module Spectator
  # Stub that responds with a static value.
  class ValueStub(T) < TypedStub(T)
    # Return value.
    getter value : T

    # Creates the stub.
    def initialize(method : Symbol, @value : T, constraint : Arguments? = nil)
      super(method, constraint)
    end
  end
end
