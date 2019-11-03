require "./arguments"
require "./method_stub"

module Spectator::Mocks
  abstract class GenericMethodStub(ReturnType) < MethodStub
    abstract def call(args : Arguments(T, NT)) : ReturnType forall T, NT
  end
end
