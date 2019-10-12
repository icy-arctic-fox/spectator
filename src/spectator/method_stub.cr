require "./source"

module Spectator
  abstract class MethodStub
    def initialize(@name : Symbol, @source : Source)
    end

    def callable?(name : Symbol, *args) : Bool
      name == @name
    end

    def call(*args)
    end
  end
end
