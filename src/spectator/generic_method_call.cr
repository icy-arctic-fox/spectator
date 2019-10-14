require "./method_call"

module Spectator
  class GenericMethodCall(T, NT) < MethodCall
    getter args : T

    getter options : NT

    def initialize(name : Symbol, @args : T, @options : NT)
      super(name)
    end
  end
end
