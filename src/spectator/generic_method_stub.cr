require "./method_stub"
require "./source"

module Spectator
  class GenericMethodStub(ReturnType, *ArgumentTypes) < MethodStub
    def callable?(name : Symbol, *args) : Bool
      super
    end

    def call(*args)
    end
  end
end
