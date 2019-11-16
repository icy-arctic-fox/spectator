require "./arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ProcMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @proc : -> ReturnType, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T2, NT2), rt : RT.class) forall T2, NT2, RT
      @proc.call
    end
  end
end
