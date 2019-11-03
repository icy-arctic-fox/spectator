require "./generic_arguments"
require "./generic_method_stub"
require "./value_method_stub"

module Spectator::Mocks
  class NilMethodStub < GenericMethodStub(Nil)
    def initialize(name, source, args = nil)
      super(name, source, args)
    end

    def call(_args : GenericArguments(T, NT)) : ReturnType forall T, NT
      nil
    end

    def and_return(value : T) forall T
      ValueMethodStub.new(@name, @source, value)
    end
  end
end
