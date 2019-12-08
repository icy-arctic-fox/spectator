require "./generic_arguments"
require "./method_call"

module Spectator::Mocks
  class GenericMethodCall(T, NT) < MethodCall
    getter args

    def initialize(name : Symbol, @args : GenericArguments(T, NT))
      super(name)
    end

    def to_s(io)
      super
      io << '('
      io << @args
      io << ')'
    end
  end
end
