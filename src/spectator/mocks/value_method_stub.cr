require "./generic_arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ValueMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @value : ReturnType, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T, NT), rt : RT.class) forall T, NT, RT
      @value
    end
  end
end
