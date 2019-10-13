require "./source"

module Spectator
  abstract class MethodStub
    def initialize(@name : Symbol, @source : Source)
    end

    def callable?(call : MethodCall) : Bool
      @name == call.name
    end
  end
end
