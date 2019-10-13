module Spectator
  class MethodCall(T, NT)
    getter name : Symbol

    getter args : T

    getter options : NT

    def initialize(@name : Symbol, @args : T, @options : NT)
    end
  end
end
