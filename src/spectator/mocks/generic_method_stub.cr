require "./arguments"
require "./generic_arguments"
require "./method_call"
require "./method_stub"

module Spectator::Mocks
  abstract class GenericMethodStub(ReturnType) < MethodStub
    getter! arguments : Arguments

    def initialize(name, source, @args : Arguments? = nil)
      super(name, source)
    end

    def callable?(call : GenericMethodCall(T, NT)) : Bool forall T, NT
      super && (!@args || @args === call.args)
    end

    def to_s(io)
      super(io)
      if @args
        io << '('
        io << @args
        io << ')'
      end
      io << " : "
      io << ReturnType
      io << " at "
      io << @source
    end
  end
end
