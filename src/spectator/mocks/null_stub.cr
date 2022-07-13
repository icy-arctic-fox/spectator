require "./typed_stub"
require "./value_stub"

module Spectator
  # Stub that does nothing and returns nil.
  class NullStub < TypedStub(Nil)
    # Invokes the stubbed implementation.
    def call(call : MethodCall) : Nil
    end

    # Returns a new stub with constrained arguments.
    def with_constraint(constraint : AbstractArguments?)
      self.class.new(method, constraint, location)
    end
  end
end
