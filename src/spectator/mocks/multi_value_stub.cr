require "../location"
require "./arguments"
require "./stub_modifiers"
require "./typed_stub"

module Spectator
  # Stub that responds with a multiple values in succession.
  class MultiValueStub(T) < TypedStub(T)
    # Invokes the stubbed implementation.
    def call(call : MethodCall) : T
      if @values.size == 1
        @values.first
      else
        @values.shift
      end
    end

    # Returns a new stub with constrained arguments.
    def with_constraint(constraint : AbstractArguments?)
      self.class.new(method, @values, constraint, location)
    end

    # Creates the stub.
    def initialize(method : Symbol, @values : Array(T), constraint : AbstractArguments? = nil, location : Location? = nil)
      super(method, constraint, location)
    end
  end

  module StubModifiers
    # Returns a new stub that returns multiple values in succession.
    def and_return(value, *values)
      MultiValueStub.new(method, [value, *values], constraint, location)
    end
  end
end
