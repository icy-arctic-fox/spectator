require "./abstract_arguments"
require "./arguments"

module Spectator
  class MethodCall
    getter method : Symbol

    getter arguments : AbstractArguments

    def initialize(@method : Symbol, @arguments : Arguments = Arguments.empty)
    end

    def self.capture(method : Symbol, *args, **kwargs)
      arguments = Arguments.new(args, kwargs)
      new(method, arguments)
    end
  end
end
