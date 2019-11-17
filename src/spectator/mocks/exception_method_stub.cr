require "./generic_arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ExceptionMethodStub(ExceptionType) < GenericMethodStub(Nil)
    def initialize(name, source, @exception : ExceptionType, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T2, NT2), rt : RT.class) forall T2, NT2, RT
      raise @exception
    end
  end
end
