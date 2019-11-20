require "./generic_arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ValueMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @value : ReturnType, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T2, NT2)) forall T2, NT2
      @value
    end
  end
end
