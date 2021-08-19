require "./arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ProcMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, location, @proc : -> ReturnType, args = nil)
      super(name, location, args)
    end

    def self.create(name, location, args = nil, &block : -> T) forall T
      ProcMethodStub.new(name, location, block, args)
    end

    def call(_args : GenericArguments(T, NT), &_original : -> RT) forall T, NT, RT
      @proc.call
    end
  end
end
