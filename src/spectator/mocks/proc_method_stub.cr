require "./arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ProcMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @proc : -> ReturnType)
      super(name, source)
    end

    def call(_args : Arguments(T, NT)) : ReturnType forall T, NT
      @proc.call
    end
  end
end
