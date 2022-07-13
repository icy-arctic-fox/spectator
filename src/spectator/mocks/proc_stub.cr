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

    # Returns a new stub with constrained arguments.
    def with_constraint(constraint : AbstractArguments?)
      self.class.new(method, @proc, constraint, location)
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

  module StubModifiers
    # Returns a new stub with an argument constraint.
    def with(*args, **kwargs, &block : AbstractArguments -> T) forall T
      constraint = Arguments.new(args, kwargs).as(AbstractArguments)
      ProcStub(T).new(method, block, constraint, location)
    end
  end
end
