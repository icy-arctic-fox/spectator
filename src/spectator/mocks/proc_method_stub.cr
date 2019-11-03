require "./arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ProcMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @proc : -> ReturnType, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T, NT)) : ReturnType forall T, NT
      @proc.call
    end
  end
end
