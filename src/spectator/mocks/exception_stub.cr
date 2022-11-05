require "../location"
require "./arguments"
require "./stub"
require "./stub_modifiers"

module Spectator
  # Stub that raises an exception.
  class ExceptionStub < Stub
    # Invokes the stubbed implementation.
    def call(call : MethodCall) : Nil
      raise @exception
    end

    # Returns a new stub with constrained arguments.
    def with_constraint(constraint : AbstractArguments?)
      self.class.new(method, @exception, constraint, location)
    end

    # Creates the stub.
    def initialize(method : Symbol, @exception : Exception, constraint : AbstractArguments? = nil, location : Location? = nil)
      super(method, constraint, location)
    end

    # String representation of the stub, formatted as a method call.
    def to_s(io : IO) : Nil
      super
      io << " # raises " << @exception
    end
  end

  module StubModifiers
    # Returns a new stub that raises an exception.
    def and_raise(exception : Exception)
      ExceptionStub.new(method, exception, constraint, location)
    end

    # :ditto:
    def and_raise(exception_class : Exception.class, message)
      exception = exception_class.new(message)
      and_raise(exception)
    end

    # :ditto:
    def and_raise(message : String? = nil)
      exception = Exception.new(message)
      and_raise(exception)
    end

    # :ditto:
    def and_raise(exception_class : Exception.class)
      exception = exception_class.new
      and_raise(exception)
    end
  end
end
