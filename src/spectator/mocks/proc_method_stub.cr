require "./arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ProcMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @proc : -> ReturnType, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T, NT), rt : RT.class) forall T, NT, RT
      result = @proc.call
      if (cast = result.as?(RT))
        cast
      else
        raise "The return type of stub #{to_s} : #{ReturnType} doesn't match the expected type #{RT}"
      end
    end
  end
end
