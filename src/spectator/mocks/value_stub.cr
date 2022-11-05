require "../location"
require "./arguments"
require "./stub_modifiers"
require "./typed_stub"

module Spectator
  # Stub that responds with a static value.
  class ValueStub(T) < TypedStub(T)
    # Invokes the stubbed implementation.
    def call(call : MethodCall) : T
      @value
    end

    # Returns a new stub with constrained arguments.
    def with_constraint(constraint : AbstractArguments?)
      self.class.new(method, @value, constraint, location)
    end

    # Creates the stub.
    def initialize(method : Symbol, @value : T, constraint : AbstractArguments? = nil, location : Location? = nil)
      super(method, constraint, location)
    end

    # String representation of the stub, formatted as a method call and return value.
    def to_s(io : IO) : Nil
      super
      io << " # => "
      @value.inspect(io)
    end
  end

  module StubModifiers
    # Returns a new stub that returns a static value.
    def and_return(value)
      ValueStub.new(method, value, constraint, location)
    end
  end
end
