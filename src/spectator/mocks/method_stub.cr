require "../source"
require "./generic_method_call"

module Spectator::Mocks
  abstract class MethodStub
    def initialize(@name : Symbol, @source : Source)
    end

    def callable?(call : GenericMethodCall(T, NT)) : Bool forall T, NT
      @name == call.name
    end

    abstract def call(args : GenericArguments(T, NT), rt : RT.class) forall T, NT, RT

    def to_s(io)
      io << '#'
      io << @name
    end
  end
end
