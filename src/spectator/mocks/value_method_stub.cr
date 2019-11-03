require "./arguments"
require "./generic_method_stub"

module Spectator::Mocks
  class ValueMethodStub(ReturnType) < GenericMethodStub(ReturnType)
    def initialize(name, source, @value : ReturnType)
      super(name, source)
    end

    def call(_args : Arguments(T, NT)) : ReturnType forall T, NT
      @value
    end

    def and_return(value : T) forall T
      ValueMethodStub.new(@name, @source, value)
    end
  end
end
