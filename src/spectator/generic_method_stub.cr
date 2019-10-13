require "./method_call"
require "./method_stub"
require "./source"

module Spectator
  class GenericMethodStub(ReturnType) < MethodStub
    def initialize(name : Symbol, source : Source, @proc : -> ReturnType)
      super(name, source)
    end

    def callable?(call : MethodCall) : Bool
      super
    end

    def call(call : MethodCall) : ReturnType
      @proc.call
    end
  end
end
