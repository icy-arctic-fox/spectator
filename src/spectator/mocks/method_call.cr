require "./abstract_arguments"
require "./arguments"
require "./formal_arguments"

module Spectator
  # Stores information about a call to a method.
  class MethodCall
    # Name of the method.
    getter method : Symbol

    # Arguments passed to the method.
    getter arguments : AbstractArguments

    # Creates a method call.
    def initialize(@method : Symbol, @arguments : AbstractArguments = Arguments.none)
    end

    # Creates a method call by splatting its arguments.
    def self.capture(method : Symbol, *args, **kwargs)
      arguments = Arguments.capture(*args, **kwargs).as(AbstractArguments)
      new(method, arguments)
    end

    # Creates a method call from within a method.
    # Takes the same arguments as `FormalArguments.build` but with the method name first.
    def self.build(method : Symbol, *args, **kwargs)
      arguments = FormalArguments.build(*args, **kwargs).as(AbstractArguments)
      new(method, arguments)
    end

    # Constructs a string containing the method name and arguments.
    def to_s(io : IO) : Nil
      io << '#' << method
      arguments.inspect(io)
    end

    # :ditto:
    def inspect(io : IO) : Nil
      to_s(io)
    end
  end
end
