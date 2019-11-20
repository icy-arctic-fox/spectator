require "./arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ProcMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @proc : -> ReturnType, args = nil)
      super(name, source, args)
    end

    def self.create(name, source, args = nil, &block : -> T) forall T
      ProcMethodStub.new(name, source, block, args)
    end

    def call(_args : GenericArguments(T2, NT2)) forall T2, NT2
      @proc.call
    end
  end
end
