require "../source"
require "./method_call"

module Spectator::Mocks
  abstract class MethodStub
    getter name : Symbol

    getter source : Source

    def initialize(@name, @source)
    end

    def callable?(call : MethodCall) : Bool
      @name == call.name
    end

    abstract def call(args : GenericArguments(T, NT), &original : -> RT) forall T, NT, RT

    def call!(args : GenericArguments(T, NT), &original : -> RT) : RT forall T, NT, RT
      value = call(args) { |*ya| yield *ya }
      if value.is_a?(RT)
        value.as(RT)
      elsif value.nil? && RT == NoReturn
        raise SystemExit.new
      else
        raise TypeCastError.new("The return type of stub #{self} doesn't match the expected type #{RT}")
      end
    end

    def to_s(io)
      io << '#'
      io << @name
    end
  end
end
